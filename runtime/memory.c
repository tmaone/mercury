#include <unistd.h>
#include "imp.h"
#include "ext_stdlib.h"
#include "ext_signal.h"

/*
** The important global variables of the execution algorithm.
** They are defined together here to allow us to control how they map
** onto direct mapped caches.
**
** We allocate a large arena, preferably aligned on a boundary that
** is a multiple of both the page size and the primary cache size.
**
** We then allocate the register arrays, the heap and the stacks
** in such a way that
**
**	the register array starts at the bottom of the primary cache
**	the bottom of the heap takes the rest of the first half of the cache
**	the bottom of the detstack takes the third quarter of the cache
**	the bottom of the nondstack takes the fourth quarter of the cache
**
** This should significantly reduce cache conflicts.
**
** If the operating system of the machine supports the mprotect syscall,
** we also protect a chunk at the end of each area against access,
** thus detecting area overflow.
*/

#include <stdio.h>
FILE *popen(const char *command, const char *type);
int pclose (FILE *stream);

#ifdef	HAVE_MPROTECT
#include <sys/mman.h>
#endif

#include <signal.h>

#ifdef	HAVE_SIGINFO
static	void	complex_bushandler(int, siginfo_t *, void *);
static	void	complex_segvhandler(int, siginfo_t *, void *);
#else
static	void	simple_sighandler(int);
#endif

#ifdef	HAVE_UCONTEXT
#include <ucontext.h>
#endif

#ifdef	HAVE_SYSCONF
#define	getpagesize()	sysconf(_SC_PAGESIZE)
#else
#ifdef	HAVE_GETPAGESIZE
extern	int	getpagesize(void);
#else
#define	getpagesize()	8192
#endif
#endif

#ifdef CONSERVATIVE_GC
#define memalign(a,s)   GC_MALLOC(s)
#else
#ifndef	HAVE_MEMALIGN
#define	memalign(a,s)	malloc(s)
#endif
#endif

#include "conf.h"

static	int	roundup(int, int);
static	void	setup_mprotect(void);
#ifdef	HAVE_SIGINFO
static	bool	try_munprotect(void *);
#endif

static	void	setup_signal(void);

Word	fake_reg[MAX_FAKE_REG];

Word	virtual_reg_map[MAX_REAL_REG] = VIRTUAL_REG_MAP_BODY;

Word	num_uses[MAX_RN];

Word	*heap;
Word	*detstack;
Word	*nondstack;

Word	*heapmin;
Word	*detstackmin;
Word	*nondstackmin;

Word	*heapmax;
Word	*detstackmax;
Word	*nondstackmax;

Word	*heapend;
Word	*detstackend;
Word	*nondstackend;

caddr_t	heap_zone;
caddr_t	detstack_zone;
caddr_t	nondstack_zone;

int	heap_zone_left = 0;
int	detstack_zone_left = 0;
int	nondstack_zone_left = 0;

static	int	unit;
static	int	page_size;

void init_memory(void)
{
	char	*arena;
	int	total_size;
	int	fake_reg_offset, heap_offset, detstack_offset, nondstack_offset;

	/*
	** Convert all the sizes are from kilobytes to bytes and
	** make sure they are multiples of the page and cache sizes.
	*/

	page_size = getpagesize();
	unit = max(page_size, pcache_size);

#ifdef CONSERVATIVE_GC
	heap_size = heap_zone_size = 0;
#else
	heap_zone_size      = roundup(heap_zone_size * 1024, unit);
	heap_size           = roundup(heap_size * 1024, unit);
#endif
	detstack_size       = roundup(detstack_size * 1024, unit);
	detstack_zone_size  = roundup(detstack_zone_size * 1024, unit);
	nondstack_size      = roundup(nondstack_size * 1024, unit);
	nondstack_zone_size = roundup(nondstack_zone_size * 1024, unit);

	/*
	** If the zone sizes where set to something too big, then
	** set them to a single unit.
	*/

#ifndef CONSERVATIVE_GC
	if (heap_zone_size >= heap_size)
		heap_zone_size = unit;
#endif

	if (detstack_zone_size >= detstack_size)
		detstack_zone_size = unit;

	if (nondstack_zone_size >= nondstack_size)
		nondstack_zone_size = unit;


	/*
	** Calculate how much memory to allocate, then allocate it
	** and divide it up among the areas.
	** We allocate 4 extra units, since we waste one unit each
	** for the heap, detstack, and nondstack to ensure they
	** are aligned at non-conflicting cache offsets, and we may
	** waste one unit aligning the whole arena on a unit boundary.
	*/

	total_size = heap_size + detstack_size + nondstack_size + 4 * unit;

	/*  get mem_size pages aligned on a page boundary */
	arena = memalign(unit, total_size);
	if (arena == NULL)
	{
		perror("Mercury runtime");
		fprintf(stderr, "cannot allocate arena: memalign() failed\n");
		exit(1);
	}
	arena = (char *) roundup((int) arena, unit);
	
	fake_reg_offset = (int) fake_reg % pcache_size;
	heap_offset = (fake_reg_offset + pcache_size / 4) % pcache_size;
	detstack_offset = (heap_offset + pcache_size / 4) % pcache_size;
	nondstack_offset = (detstack_offset + pcache_size / 4) % pcache_size;

#ifdef CONSERVATIVE_GC
	heap = heapmin = heapend = 0;
#else
	heap    = (Word *) arena;
	heapmin = (Word *) ((char *) heap + heap_offset);
	heapend = (Word *) ((char *) heap + heap_size + unit);
	assert(((int) heapend) % unit == 0);
#endif

#ifdef CONSERVATIVE_GC
	detstack    = (Word *) arena;
#else
	detstack    = heapend;
#endif
	detstackmin = (Word *) ((char *) detstack + detstack_offset);
	detstackend = (Word *) ((char *) detstack + detstack_size + unit);
	assert(((int) detstackend) % unit == 0);

	nondstack    = detstackend;
	nondstackmin = (Word *) ((char *) nondstack + nondstack_offset);
	nondstackend = (Word *) ((char *) nondstack + nondstack_size + unit);
	assert(((int) nondstackend) % unit == 0);

#ifndef	SPEED
	nondstackmin[PREDNM] = (Word) "bottom";
#endif

	if (arena + total_size <= (char *) nondstackend)
	{
		fprintf(stderr, "Mercury runtime: allocated too much memory\n");
		exit(1);
	}

	setup_mprotect();
	setup_signal();

	if (memdebug)
	{

		printf("\n");
		printf("pcache_size  = %d (0x%x)\n", pcache_size, pcache_size);
		printf("page_size    = %d (0x%x)\n", page_size, page_size);
		printf("unit         = %d (0x%x)\n", unit, unit);

		printf("\n");
		printf("fake_reg       = %p (offset %d)\n", (void *) fake_reg,
			(int) fake_reg & (unit-1));
		printf("\n");

		printf("heap           = %p (offset %d)\n", (void *) heap,
			(int) heap & (unit-1));
		printf("heapmin        = %p (offset %d)\n", (void *) heapmin,
			(int) heapmin & (unit-1));
		printf("heapend        = %p (offset %d)\n", (void *) heapend,
			(int) heapend & (unit-1));
		printf("heap_zone      = %p (offset %d)\n", (void *) heap_zone,
			(int) heap_zone & (unit-1));

		printf("\n");
		printf("detstack       = %p (offset %d)\n", (void *) detstack,
			(int) detstack & (unit-1));
		printf("detstackmin    = %p (offset %d)\n", (void *) detstackmin,
			(int) detstackmin & (unit-1));
		printf("detstackend    = %p (offset %d)\n", (void *) detstackend,
			(int) detstackend & (unit-1));
		printf("detstack_zone  = %p (offset %d)\n", (void *) detstack_zone,
			(int) detstack_zone & (unit-1));

		printf("\n");
		printf("nondstack      = %p (offset %d)\n", (void *) nondstack,
			(int) nondstack & (unit-1));
		printf("nondstackmin   = %p (offset %d)\n", (void *) nondstackmin,
			(int) nondstackmin & (unit-1));
		printf("nondstackend   = %p (offset %d)\n", (void *) nondstackend,
			(int) nondstackend & (unit-1));
		printf("nondstack_zone = %p (offset %d)\n", (void *) nondstack_zone,
			(int) nondstack_zone & (unit-1));

		printf("\n");
		printf("arena start    = %p (offset %d)\n", (void *) arena,
			(int) arena & (unit-1));
		printf("arena end      = %p (offset %d)\n", (void *) (arena+total_size),
			(int) (arena+total_size) & (unit-1));

		printf("\n");
		printf("heap size      = %d (0x%x)\n",
			(char *) heapend - (char *) heapmin,
			(char *) heapend - (char *) heapmin);
		printf("detstack size  = %d (0x%x)\n",
			(char *) detstackend - (char *) detstackmin,
			(char *) detstackend - (char *) detstackmin);
		printf("nondstack size = %d (0x%x)\n",
			(char *) nondstackend - (char *) nondstackmin,
			(char *) nondstackend - (char *) nondstackmin);
		printf("arena size     = %d (0x%x)\n", total_size, total_size);
	}
}

static int roundup(int value, int align)
{
	if ((value & (align - 1)) != 0)
		value += align - (value & (align - 1));

	return value;
}

#ifdef	HAVE_MPROTECT

/*
** DESCRIPTION
**  The function mprotect() changes the  access  protections  on
**  the mappings specified by the range [addr, addr + len) to be
**  that specified by prot.  Legitimate values for prot are  the
**  same  as  those  permitted  for  mmap  and  are  defined  in
**  <sys/mman.h> as:
**
** PROT_READ    page can be read 
** PROT_WRITE   page can be written
** PROT_EXEC    page can be executed
** PROT_NONE    page can not be accessed
*/

#ifdef CONSERVATIVE_GC
	/*
	** The conservative garbage collectors scans through
	** all these areas, so we need to allow reads.
	** XXX This probably causes efficiency problems:
	** too much memory for the GC to scan, and it probably
	** all gets paged it.
	*/
#define MY_PROT PROT_READ
#else
#define MY_PROT PROT_NONE
#endif

static void setup_mprotect(void)
{
	heap_zone_left = heap_zone_size;
	heap_zone = (caddr_t) (heapend) - heap_zone_size;
	if (heap_zone_size > 0
	    && mprotect(heap_zone, heap_zone_size, MY_PROT) != 0)
	{
		perror("Mercury runtime: cannot protect heap redzone");
		exit(1);
	}

	detstack_zone_left = detstack_zone_size;
	detstack_zone = (caddr_t) (detstackend) - detstack_zone_size;
	if (detstack_zone_size > 0
	    && mprotect(detstack_zone, detstack_zone_size, MY_PROT) != 0)
	{
		perror("Mercury runtime: cannot protect detstack redzone");
		exit(1);
	}

	nondstack_zone_left = nondstack_zone_size;
	nondstack_zone = (caddr_t) (nondstackend) - nondstack_zone_size;
	if (nondstack_zone_size > 0
	    && mprotect(nondstack_zone, nondstack_zone_size, MY_PROT) != 0)
	{
		perror("Mercury runtime: cannot protect nondstack redzone");
		exit(1);
	}
}

#ifdef HAVE_SIGINFO	/* try_munprotect is only useful if we have SIGINFO */

static bool try_munprotect(void *addr)
{
	caddr_t	fault_addr;
	caddr_t	new_zone;

	fault_addr = (caddr_t) addr;

	if (heap_zone != NULL && heap_zone <= fault_addr
	&& fault_addr <= heap_zone + heap_zone_size)
	{
		printf("address is in heap red zone\n");
		new_zone = (caddr_t) roundup((int) fault_addr+4, unit);
		if (new_zone <= heap_zone + heap_zone_left)
		{
			printf("trying to unprotect from %p to %p\n",
				(void *) heap_zone, (void *) new_zone);

			if (new_zone >= (caddr_t) heapend)
			{
				printf("cannot unprotect last page\n");
				return FALSE;
			}

			if (mprotect(heap_zone, new_zone-heap_zone, PROT_READ|PROT_WRITE) != 0)
			{
				perror("Mercury runtime: cannot unprotect heap\n");
				exit(1);
			}

			heap_zone_left -= new_zone-heap_zone;
			heap_zone = new_zone;
			printf("successful, heap_zone now %p\n",
				(void *) heap_zone);

			/* printf("value at fault addr %p is %d\n",
				(void *) addr, * ((Word *) addr)); */
			return TRUE;
		}
	}
	or (detstack_zone != NULL && detstack_zone <= fault_addr
	&& fault_addr <= detstack_zone + detstack_zone_size)
	{
		printf("address is in detstack red zone\n");
		new_zone = (caddr_t) roundup((int) fault_addr+4, unit);
		if (new_zone <= detstack_zone + detstack_zone_left)
		{
			printf("trying to unprotect from %p to %p\n",
				(void *) detstack_zone, (void *) new_zone);

			if (new_zone >= (caddr_t) detstackend)
			{
				printf("cannot unprotect last page\n");
				return FALSE;
			}

			if (mprotect(detstack_zone, new_zone-detstack_zone, PROT_READ|PROT_WRITE) != 0)
			{
				perror("Mercury runtime: cannot unprotect detstack\n");
				exit(1);
			}

			detstack_zone_left -= new_zone-detstack_zone;
			detstack_zone = new_zone;
			printf("successful, detstack_zone now %p\n",
				(void *) detstack_zone);

			/* printf("value at fault addr %p is %d\n",
				(void *) addr, * ((Word *) addr)); */
			return TRUE;
		}
	}
	or (nondstack_zone != NULL && nondstack_zone <= fault_addr
	&& fault_addr <= nondstack_zone + nondstack_zone_size)
	{
		printf("address is in nondstack red zone\n");
		new_zone = (caddr_t) roundup((int) fault_addr+4, unit);
		if (new_zone <= nondstack_zone + nondstack_zone_left)
		{
			printf("trying to unprotect from %p to %p\n",
				(void *) nondstack_zone, (void *) new_zone);

			if (new_zone >= (caddr_t) nondstackend)
			{
				printf("cannot unprotect last page\n");
				return FALSE;
			}

			if (mprotect(nondstack_zone, new_zone-nondstack_zone, PROT_READ|PROT_WRITE) != 0)
			{
				perror("Mercury runtime: cannot unprotect nondstack\n");
				exit(1);
			}

			nondstack_zone_left -= new_zone-nondstack_zone;
			nondstack_zone = new_zone;
			printf("successful, nondstack_zone now %p\n",
				(void *) nondstack_zone);

			/* printf("value at fault addr %p is %d\n",
				(void *) addr, * ((Word *) addr)); */
			return TRUE;
		}
	}

	return FALSE;
}

#endif /* HAVE_SIGINFO */

#else /* not HAVE_MPROTECT */

static void setup_mprotect(void)
{
	heap_zone      = NULL;
	detstack_zone  = NULL;
	nondstack_zone = NULL;
}

#ifdef HAVE_SIGINFO	/* try_munprotect is only useful if we have SIGINFO */

static bool try_munprotect(void *addr)
{
	return FALSE;
}

#endif /* HAVE_SIGINFO */

#endif /* not HAVE_MPROTECT */

#ifdef	HAVE_SIGINFO

static void setup_signal(void)
{
	struct sigaction	act;

	act.sa_flags = SA_SIGINFO | SA_RESTART;
	if (sigemptyset(&act.sa_mask) != 0)
	{
		perror("Mercury runtime: cannot set clear signal mask");
		exit(1);
	}

	act.sa_sigaction = complex_bushandler;
	if (sigaction(SIGBUS, &act, NULL) != 0)
	{
		perror("Mercury runtime: cannot set SIGBUS handler");
		exit(1);
	}

	act.sa_sigaction = complex_segvhandler;
	if (sigaction(SIGSEGV, &act, NULL) != 0)
	{
		perror("Mercury runtime: cannot set SIGSEGV handler");
		exit(1);
	}
}

static void complex_bushandler(int sig, siginfo_t *info, void *context)
{
	if (sig != SIGBUS || info->si_signo != SIGBUS)
	{
		printf("\n*** caught strange bus error ***\n");
		exit(1);
	}

	printf("\n*** caught bus error ***\n");

	if (info->si_code > 0)
	{
		printf("cause: ");
		switch (info->si_code)
		{

	case BUS_ADRALN:	printf("invalid address alignment\n");
	when BUS_ADRERR:	printf("non-existent physical address\n");
	when BUS_OBJERR:	printf("object specific hardware error\n");
	otherwise:		printf("unknown\n");

		}

		printf("address involved: %p\n", (void *) info->si_addr);
	}

	exit(1);
}

static void complex_segvhandler(int sig, siginfo_t *info, void *context)
{
	if (sig != SIGSEGV || info->si_signo != SIGSEGV)
	{
		printf("\n*** caught strange segmentation violation ***\n");
		exit(1);
	}

	printf("\n*** caught segmentation violation ***\n");

	if (info->si_code > 0)
	{
		printf("cause: ");
		switch (info->si_code)
		{

	case SEGV_MAPERR:	printf("address not mapped to object\n");
	when SEGV_ACCERR:	printf("invalid permissions for mapped object\n");
	otherwise:		printf("unknown\n");

		}

		printf("PC at signal: %d (%x)\n",
			((ucontext_t *) context)->uc_mcontext.gregs[PC_INDEX],
			((ucontext_t *) context)->uc_mcontext.gregs[PC_INDEX]);
		printf("address involved: %p\n", (void *) info->si_addr);

		if (try_munprotect(info->si_addr))
		{
			printf("returning from signal handler\n\n");
			return;
		}
	}

	printf("exiting from signal handler\n");
	exit(1);
}

#else

static void setup_signal(void)
{
	if (signal(SIGBUS, simple_sighandler) == SIG_ERR)
	{
		perror("cannot set SIGBUS handler");
		exit(1);
	}

	if (signal(SIGSEGV, simple_sighandler) == SIG_ERR)
	{
		perror("cannot set SIGSEGV handler");
		exit(1);
	}
}

static void simple_sighandler(int sig)
{
	switch (sig)
	{

case SIGBUS: 	printf("*** caught bus error ***\n");

when SIGSEGV: 	printf("*** caught segmentation violation ***\n");

otherwise:	printf("*** caught unknown signal ***\n");

	}

	exit(1);
}

#endif
