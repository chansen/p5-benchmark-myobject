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

#ifndef PERL_MAGIC_ext
#  define PERL_MAGIC_ext '~'
#endif

#ifndef PTR2UV
#  define PTR2UV(ptr) (UV)(ptr)
#endif

#ifndef newSVuv
#  define newSVuv newSViv
#endif

#if (__STDC_VERSION__ >= 199901L) || (__GNUC__ >= 3)
#  define INLINE inline
#else
#  define INLINE
#endif

#define AIO_MAGIC_SIGNATURE 0x414F

STATIC INLINE void
set_attribute_store(pTHX_ CV *cv, HV *store) {
#define set_attribute_store(a, b) set_attribute_store(aTHX_ a, b)
    MAGIC *mg;

    sv_magic((SV *)cv, (SV *)store, PERL_MAGIC_ext, NULL, 0);
    mg = SvMAGIC((SV *)cv);
    mg->mg_private = AIO_MAGIC_SIGNATURE;
}

STATIC INLINE HV *
get_attribute_store(pTHX_ CV *cv) {
#define get_attribute_store(a) get_attribute_store(aTHX_ a)
    MAGIC *mg;

    for (mg = SvMAGIC((SV *)cv); mg; mg = mg->mg_moremagic)
        if (mg->mg_type == PERL_MAGIC_ext && mg->mg_private == AIO_MAGIC_SIGNATURE)
            return (HV *)mg->mg_obj;

    croak("Couldn't find attribute store for sub %s", GvNAME(CvGV(cv)));
}

STATIC INLINE SV *
get_instance_key(pTHX_ SV *sv) {
#define get_instance_key(a) get_instance_key(aTHX_ a)
    SvGETMAGIC(sv);
    if (!SvROK(sv))
        croak("object is not a reference");
    sv = SvRV(sv);
    return sv_2mortal(newSVuv(PTR2UV(sv)));
}

XS(XS_MyObject__HvInsideOutXS_accessor)
{
    dXSARGS; dXSTARG;

    HV *store;
    SV *key;
    HE *he;

    if (items != 1) {
        const char *method = GvNAME(CvGV(cv));
        croak("Usage: $object->%s()", method);
    }

    key = get_instance_key(ST(0));
    store = get_attribute_store(cv);

    he = hv_fetch_ent(store, key, 0, 0);
    sv_setsv(TARG, he ? HeVAL(he) : &PL_sv_undef);
    XSprePUSH; PUSHTARG;
}

XS(XS_MyObject__HvInsideOutXS_mutator)
{
    dXSARGS;

    HV *store;
    SV *key;

    if (items != 2) {
        const char *method = GvNAME(CvGV(cv));
        croak("Usage: $object->%s(value)", method);
    }

    key = get_instance_key(ST(0));
    store = get_attribute_store(cv);

    hv_store_ent(store, key, newSVsv(ST(1)), 0);
    XSRETURN(0);
}

XS(XS_MyObject__HvInsideOutXS_predicate)
{
    dXSARGS;

    HV *store;
    SV *key;

    if (items != 1) {
        const char *method = GvNAME(CvGV(cv));
        croak("Usage: $object->%s()", method);
    }

    key = get_instance_key(ST(0));
    store = get_attribute_store(cv);

    ST(0) = boolSV(hv_exists_ent(store, key, 0));
    XSRETURN(1);
}

STATIC void
mk_accessor(pTHX_ char *name, HV *store) {
#define mk_accessor(a, b) mk_accessor(aTHX_ a, b)
    CV *cv = newXS(name, XS_MyObject__HvInsideOutXS_accessor, __FILE__);
    set_attribute_store(cv, store);
}

STATIC void
mk_mutator(pTHX_ char *name, HV *store) {
#define mk_mutator(a, b) mk_mutator(aTHX_ a, b)
    CV *cv = newXS(name, XS_MyObject__HvInsideOutXS_mutator, __FILE__);
    set_attribute_store(cv, store);
}

STATIC void
mk_predicate(pTHX_ char *name, HV *store) {
#define mk_predicate(a, b) mk_predicate(aTHX_ a, b)
    CV *cv = newXS(name, XS_MyObject__HvInsideOutXS_predicate, __FILE__);
    set_attribute_store(cv, store);
}

STATIC void
mk_attribute(pTHX_ char *name, HV *store) {
#define mk_attribute(a, b) mk_attribute(aTHX_ a, b)
    char buf[256];

    strncpy(buf, "get_", sizeof(buf));
    strcat(buf, name);

    mk_accessor(buf, store);

    strncpy(buf, "set_", sizeof(buf));
    strcat(buf, name);

    mk_mutator(buf, store);

    strncpy(buf, "has_", sizeof(buf));
    strcat(buf, name);

    mk_predicate(buf, store);
}

MODULE = MyObject::HvInsideOutXS  PACKAGE = MyObject::HvInsideOutXS

PROTOTYPES: DISABLE

void
mk_attribute(name, store)

  PROTOTYPE: $\%

  INPUT:
    char *name
    SV *store

  PPCODE:
    if (!SvROK(store) || SvTYPE(SvRV(store)) != SVt_PVHV)
        croak("store is not a HASH reference");

    mk_attribute(name, (HV *)SvRV(store));

