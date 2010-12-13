#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef aTHX_
# define aTHX_
# define pTHX_
#endif

#ifndef dXSTARG
#  define dXSTARG SV * targ = sv_newmortal()
#endif

#ifndef XSprePUSH
#  define XSprePUSH (sp = PL_stack_base + ax - 1)
#endif

#ifndef INT2PTR
#  define INT2PTR(s, p) (s)(IV)(p)
#endif

static void *
object_from_sv(pTHX_ SV *sv, const char *package, const HV *stash) {

     if (!SvOK(sv) || !SvROK(sv) || !(SvSTASH(SvRV(sv)) == stash || sv_derived_from(sv, package)))
         croak("scalar is not of type %s", package);

     return INT2PTR(void *, SvIV((SV *)SvRV(sv)));
}

static SV *
object_to_sv(pTHX_ void *object, const char *package) {

    SV *sv = newSV(0);
    sv_setref_pv(sv, package, object);
    return sv;
}

typedef struct {
  SV *content;
  SV *content_type;
} myobject_xs;

typedef myobject_xs * MyObject__XS;

#define __PACKAGE__ "MyObject::XS"
static HV * __STASH__;


MODULE = MyObject::XS  PACKAGE = MyObject::XS

PROTOTYPES: DISABLE

BOOT: 
{
    __STASH__ = gv_stashpv(__PACKAGE__, TRUE);
}

SV *
new(package)

  INPUT:
    char *package

  PREINIT:
    myobject_xs *object;

  CODE:
    Newz(0, object, 1, myobject_xs);
    RETVAL = object_to_sv(aTHX_ object, package);

  OUTPUT:
    RETVAL

void
DESTROY(self)

  INPUT:
    MyObject::XS self

  CODE:
    if (self->content) {
        SvREFCNT_dec(self->content);
        self->content = NULL;
    }

    if (self->content_type) {
        SvREFCNT_dec(self->content_type);
        self->content_type = NULL;
    }

    Safefree(self);

void
set_content(self, content)

  INPUT:
    MyObject::XS self
    SV *content

  PPCODE:
    self->content = newSVsv(content);

void
get_content(self)

  INPUT:
    MyObject::XS self

  PREINIT:
    dXSTARG;

  PPCODE:
    sv_setsv(TARG, self->content ? self->content : &PL_sv_undef);
    XSprePUSH; PUSHTARG;

bool
has_content(self)

  INPUT:
    MyObject::XS self

  CODE:
    RETVAL = !!self->content;

  OUTPUT:
    RETVAL

void
set_content_type(self, content_type)

  INPUT:
    MyObject::XS self
    SV *content_type

  PPCODE:
    self->content_type = newSVsv(content_type);

void
get_content_type(self)

  INPUT:
    MyObject::XS self

  PREINIT:
    dXSTARG;

  PPCODE:
    sv_setsv(TARG, self->content_type ? self->content_type : &PL_sv_undef);
    XSprePUSH; PUSHTARG;

bool
has_content_type(self)

  INPUT:
    MyObject::XS self

  CODE:
    RETVAL = !!self->content_type;

  OUTPUT:
    RETVAL


