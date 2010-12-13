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

#define CONTENT_str "content"
#define CONTENT_len (sizeof(CONTENT_str) - 1)
static SV *CONTENT_key;
static U32 CONTENT_hash;

#define CONTENT_TYPE_str "content_type"
#define CONTENT_TYPE_len (sizeof(CONTENT_TYPE_str) - 1)
static SV *CONTENT_TYPE_key;
static U32 CONTENT_TYPE_hash;

#define ensure_hvref(sv)                                     \
    STMT_START {                                             \
        if (!SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV)      \
            croak("reftype("#sv") is not a HASH reference"); \
    } STMT_END

MODULE = MyObject::HvRefXS  PACKAGE = MyObject::HvRefXS

PROTOTYPES: DISABLE

BOOT:
{
    CONTENT_key = newSVpvn(CONTENT_str, CONTENT_len);
    CONTENT_TYPE_key = newSVpvn(CONTENT_TYPE_str, CONTENT_TYPE_len);
    PERL_HASH(CONTENT_hash, CONTENT_str, CONTENT_len);
    PERL_HASH(CONTENT_TYPE_hash, CONTENT_TYPE_str, CONTENT_TYPE_len);
}

void
get_content(object)

  INPUT:
    SV *object

  PREINIT:
    HE *he;

  PPCODE:
    ensure_hvref(object);
    he = hv_fetch_ent((HV *)SvRV(object), CONTENT_key, 0, CONTENT_hash);
    ST(0) = (he) ? SvREFCNT_inc(HeVAL(he)) : &PL_sv_undef;
    XSRETURN(1);

void
has_content(object)

  INPUT:
    SV *object

  PPCODE:
    ensure_hvref(object);
    ST(0) = boolSV(hv_exists_ent((HV *)SvRV(object), CONTENT_key, CONTENT_hash));
    XSRETURN(1);

void
set_content(object, content)

  INPUT:
    SV *object
    SV *content

  PPCODE:
    ensure_hvref(object);
    hv_store_ent((HV *)SvRV(object), CONTENT_key, newSVsv(content), CONTENT_hash);

void
get_content_type(object)

  INPUT:
    SV *object

  PREINIT:
    HE *he;

  PPCODE:
    dXSTARG;
    ensure_hvref(object);
    he = hv_fetch_ent((HV *)SvRV(object), CONTENT_TYPE_key, 0, CONTENT_TYPE_hash);
    sv_setsv(TARG, he ? HeVAL(he) : &PL_sv_undef);
    XSprePUSH; PUSHTARG;

void
set_content_type(object, content_type)

  INPUT:
    SV *object;
    SV *content_type;

  PPCODE:
    ensure_hvref(object);
    hv_store_ent((HV *)SvRV(object), CONTENT_TYPE_key, newSVsv(content_type), CONTENT_TYPE_hash);

void
has_content_type(object)

  INPUT:
    SV *object

  PPCODE:
    dXSTARG;
    ensure_hvref(object);
    sv_setsv(TARG, hv_exists_ent((HV *)SvRV(object), CONTENT_TYPE_key, CONTENT_TYPE_hash) ? &PL_sv_yes : &PL_sv_no);
    XSprePUSH; PUSHTARG;

