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

#define ensure_avref(sv)                                      \
    STMT_START {                                              \
        if (!SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVAV)       \
            croak("reftype("#sv") is not a ARRAY reference"); \
    } STMT_END

#define CONTENT_idx      0
#define CONTENT_TYPE_idx 1

MODULE = MyObject::AvRefXS  PACKAGE = MyObject::AvRefXS

PROTOTYPES: DISABLE

void
get_content(object)

  INPUT:
    SV *object

  PREINIT:
    SV **elements;

  PPCODE:
    dXSTARG;
    ensure_avref(object);
    elements = av_fetch((AV *)SvRV(object), CONTENT_idx, 0);
    sv_setsv(TARG, elements ? elements[0] : &PL_sv_undef);
    XSprePUSH; PUSHTARG;

void
set_content(object, content)

  INPUT:
    SV *object
    SV *content

  PPCODE:
    ensure_avref(object);
    av_store((AV *)SvRV(object), CONTENT_idx, newSVsv(content));

bool
has_content(object)

  INPUT:
    SV *object

  CODE:
    ensure_avref(object);
    RETVAL = av_exists((AV *)SvRV(object), CONTENT_idx);

  OUTPUT:
    RETVAL

void
get_content_type(object)

  INPUT:
    SV *object

  PREINIT:
    SV **elements;

  PPCODE:
    dXSTARG;
    ensure_avref(object);
    elements = av_fetch((AV *)SvRV(object), CONTENT_TYPE_idx, 0);
    sv_setsv(TARG, elements ? elements[0] : &PL_sv_undef);
    XSprePUSH; PUSHTARG;

void
set_content_type(object, content_type)

  INPUT:
    SV *object
    SV *content_type

  PPCODE:
    ensure_avref(object);
    av_store((AV *)SvRV(object), CONTENT_TYPE_idx, newSVsv(content_type));

bool
has_content_type(object)

  INPUT:
    SV *object

  CODE:
    ensure_avref(object);
    RETVAL = av_exists((AV *)SvRV(object), CONTENT_TYPE_idx);

  OUTPUT:
    RETVAL

