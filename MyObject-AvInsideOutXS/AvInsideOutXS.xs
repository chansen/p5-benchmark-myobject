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

#if (__STDC_VERSION__ >= 199901L) || (__GNUC__ >= 3)
#  define INLINE inline
#else
#  define INLINE
#endif

#define AIO_MAGIC_SIGNATURE 0x414F

STATIC INLINE void
set_attribute_store(pTHX_ CV *cv, AV *av) {
#define set_attribute_store(a, b) set_attribute_store(aTHX_ a, b)
    MAGIC *mg;

    sv_magic((SV *)cv, (SV *)av, PERL_MAGIC_ext, NULL, 0);
    mg = SvMAGIC((SV *)cv);
    mg->mg_private = AIO_MAGIC_SIGNATURE;
}

STATIC INLINE AV *
get_attribute_store(pTHX_ CV *cv) {
#define get_attribute_store(a) get_attribute_store(aTHX_ a)
    MAGIC *mg;

    for (mg = SvMAGIC((SV *)cv); mg; mg = mg->mg_moremagic)
        if (mg->mg_type == PERL_MAGIC_ext && mg->mg_private == AIO_MAGIC_SIGNATURE)
            return (AV *)mg->mg_obj;

    croak("Couldn't find attribute store for sub %s", GvNAME(CvGV(cv)));
}

STATIC INLINE IV
get_instance_key(pTHX_ SV *sv) {
#define get_instance_key(a) get_instance_key(aTHX_ a)
    SvGETMAGIC(sv);
    if (!SvROK(sv))
        croak("object is not a reference");
    sv = SvRV(sv);
    if (!SvIOK(sv))
        croak("object is not a INTEGER reference");
    return SvIV(sv);
}

XS(XS_MyObject__AvInsideOutXS_accessor)
{
    dXSARGS; dXSTARG;

    AV *store;
    I32 key;
    SV **elements;

    if (items != 1) {
        const char *method = GvNAME(CvGV(cv));
        croak("Usage: $object->%s()", method);
    }

    key = get_instance_key(ST(0));
    store = get_attribute_store(cv);

    /* warn("refaddr 0x%X", PTR2UV(av)); */

    elements = av_fetch(store, key, 0);
    sv_setsv(TARG, elements ? elements[0] : &PL_sv_undef);
    XSprePUSH; PUSHTARG;
}

XS(XS_MyObject__AvInsideOutXS_mutator)
{
    dXSARGS;

    AV *store;
    I32 key;

    if (items != 2) {
        const char *method = GvNAME(CvGV(cv));
        croak("Usage: $object->%s(value)", method);
    }

    key = get_instance_key(ST(0));
    store = get_attribute_store(cv);

    av_store(store, key, newSVsv(ST(1)));
    XSRETURN(0);
}

XS(XS_MyObject__AvInsideOutXS_predicate)
{
    dXSARGS;

    AV *store;
    I32 key;

    if (items != 1) {
        const char *method = GvNAME(CvGV(cv));
        croak("Usage: $object->%s()", method);
    }

    key = get_instance_key(ST(0));
    store = get_attribute_store(cv);

    ST(0) = boolSV(av_exists(store, key));
    XSRETURN(1);
}

STATIC void
mk_accessor(pTHX_ char *name, AV *av) {

    CV *cv = newXS(name, XS_MyObject__AvInsideOutXS_accessor, __FILE__);
    set_attribute_store(cv, av);
}

STATIC void
mk_mutator(pTHX_ char *name, AV *av) {

    CV *cv = newXS(name, XS_MyObject__AvInsideOutXS_mutator, __FILE__);
    set_attribute_store(cv, av);
}

STATIC void
mk_predicate(pTHX_ char *name, AV *av) {

    CV *cv = newXS(name, XS_MyObject__AvInsideOutXS_predicate, __FILE__);
    set_attribute_store(cv, av);
}

STATIC void
mk_attribute(pTHX_ char *name, AV *av) {

    char buf[256];

    strncpy(buf, "get_", sizeof(buf));
    strcat(buf, name);

    mk_accessor(aTHX_ buf, av);

    strncpy(buf, "set_", sizeof(buf));
    strcat(buf, name);

    mk_mutator(aTHX_ buf, av);

    strncpy(buf, "has_", sizeof(buf));
    strcat(buf, name);

    mk_predicate(aTHX_ buf, av);
}

MODULE = MyObject::AvInsideOutXS  PACKAGE = MyObject::AvInsideOutXS

PROTOTYPES: DISABLE

void
mk_attribute(name, array)

  PROTOTYPE: $\@

  INPUT:
    char *name
    SV *array

  PPCODE:
    if (!SvROK(array) || SvTYPE(SvRV(array)) != SVt_PVAV)
        croak("array is not a ARRAY reference");

    mk_attribute(aTHX_ name, (AV *)SvRV(array));

