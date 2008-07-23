/*
	StringFormat.xs
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#define HINT_KEY "Acme::StringFormat"

#define my_SvPOK(sv) (SvFLAGS(sv) & (SVf_POK | SVp_POK))

static UV sf_depth = 0;

typedef OP* (*ck_t)(pTHX_ OP*);

static ck_t sf_old_ck_modulo = NULL;

static OP*
sf_pp_modulo(pTHX){
	dVAR; dSP;
	SV* lhs = TOPm1s; /* top minus 1 scalar */
	SV* rhs = TOPs;

	if( my_SvPOK(lhs) ){
		dTARGET;
		STRLEN len;
		const char* start = SvPV_const(lhs, len);
		register const char* p     = start;
		register const char* end   = start + len;

		bool maybe_tainted = FALSE; /* not used */

		/* first */
		while(p < end){
			if(*p == '%' && *(p+1) != '%'){
				p++;
				break;
			}
			p++;
		}
		if(p == end && ckWARN(WARN_PRINTF)){
			Perl_warner(aTHX_ packWARN(WARN_PRINTF), "Arguments mismatch for %s", HINT_KEY);
		}

		/* second */
		while(p < end){
			if(*p == '%' && *(p+1) != '%'){
				break;
			}
			p++;
		}
		if(p != end) p--;

		sv_vsetpvfn(TARG, start, (STRLEN)(p - start), NULL, &rhs, 1, &maybe_tainted);

		sv_catpvn(TARG, p, (STRLEN)(end - p));

		if(SvTAINTED(lhs)) SvTAINTED_on(TARG);
		if(SvUTF8(lhs))    SvUTF8_on(TARG);

		if(opASSIGN){
			sv_setsv(lhs, TARG);
			TARG = lhs;
		}

		SP--;
		SETs(TARG);
		RETURN;
	}

	return PL_ppaddr[OP_MODULO](aTHX);
}


static OP*
sf_ck_modulo(pTHX_ OP* o){
	HV* hint_hv = GvHV(PL_hintgv);
	SV** svp;

	if(hint_hv && (svp = hv_fetchs(hint_hv, HINT_KEY, FALSE))
		&& *svp && SvOK(*svp)){

		o->op_flags |= OPf_SPECIAL;
		o->op_ppaddr = sf_pp_modulo;
	}
	return sf_old_ck_modulo(aTHX_ o);
}

MODULE = Acme::StringFormat		PACKAGE = Acme::StringFormat

PROTOTYPES: DISABLE

SV*
_enter(...)
CODE:
	PERL_UNUSED_ARG(items);
	if(sf_depth == 0){
		sf_old_ck_modulo = PL_check[OP_MODULO];
		PL_check[OP_MODULO] = sf_ck_modulo;
	}
	sf_depth++;
	RETVAL = newSV(0);
	sv_setref_uv(RETVAL, HINT_KEY, sf_depth);
OUTPUT:
	RETVAL

void
DESTROY(...)
CODE:
	PERL_UNUSED_ARG(items);
	if(sf_depth == 0){
		Perl_croak(aTHX_ "panic: %s scope underflow", HINT_KEY);
	}
	if(sf_depth == 1){
		PL_check[OP_MODULO]       = sf_old_ck_modulo;
	}
	sf_depth--;

