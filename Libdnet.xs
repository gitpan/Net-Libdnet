/* $Id: Libdnet.xs,v 1.3 2004/09/06 14:43:12 vman Exp $ */

/* Copyright (c) 2004 Vlad Manilici
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdio.h>
#include <dnet.h>

HV * intf2hash(struct intf_entry *IeInt){
	HV *HvInt, *HvUndef;
	SV *SvData, *SvKey;
	char *StrAddr;

	/* prepare undefined hash */
	HvUndef = newHV();
	hv_undef(HvUndef);

	HvInt = newHV();

	/* intf_len */
	SvKey = newSVpv("len", 0);
	SvData = newSVnv((double) IeInt->intf_len);
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_len\n");
		return HvUndef;
	}

	/* intf_name */
	SvKey = newSVpv("name", 0);
	SvData = newSVpv(IeInt->intf_name, 0);
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: int_name\n");
		return HvUndef;
	}

	/* intf_type */
	SvKey = newSVpv("type", 0);
	SvData = newSVnv((double) IeInt->intf_type);
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_type\n");
		return HvUndef;
	}

	/* intf_flags */
	SvKey = newSVpv("flags", 0);
	SvData = newSVnv((double) IeInt->intf_flags);
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_flags\n");
		return HvUndef;
	}

	/* intf_mtu */
	SvKey = newSVpv("mtu", 0);
	SvData = newSVnv((double) IeInt->intf_mtu);
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_mtu\n");
		return HvUndef;
	}

	/* intf_addr */
	SvKey = newSVpv("addr", 0);
	/* does not allways exist */
	StrAddr = addr_ntoa(&(IeInt->intf_addr));
	if( StrAddr == NULL ){
		SvData = &PL_sv_undef;
	}else{
		SvData = newSVpv(addr_ntoa(&(IeInt->intf_addr)), 0);
	}
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_addr\n");
		return HvUndef;
	}

	/* intf_dst_addr */
	SvKey = newSVpv("dst_addr", 0);
	/* does not allways exist */
	StrAddr = addr_ntoa(&(IeInt->intf_dst_addr));
	if( StrAddr == NULL ){
		SvData = &PL_sv_undef;
	}else{
		SvData = newSVpv(addr_ntoa(&(IeInt->intf_dst_addr)), 0);
	}
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_dst_addr\n");
		return HvUndef;
	}

	/* intf_link_addr */
	SvKey = newSVpv("link_addr", 0);
	/* does not allways exist */
	StrAddr = addr_ntoa(&(IeInt->intf_link_addr));
	if( StrAddr == NULL ){
		SvData = &PL_sv_undef;
	}else{
		SvData = newSVpv(addr_ntoa(&(IeInt->intf_link_addr)), 0);
	}
	if( hv_store_ent(HvInt, SvKey, SvData, 0) == NULL ){
		warn("intf2hash: error: intf_link_addr\n");
		return HvUndef;
	}

	/* XXX skipped the aliases problematic */

	return HvInt;
}

MODULE=Net::Libdnet PACKAGE=Net::Libdnet

SV *
addr_cmp(SvA, SvB)
		SV *SvA;
		SV *SvB;
	PROTOTYPE: $$
	CODE:
		char *StrA, *StrB;
		struct addr SadA, SadB;
		int len;

		/*
		we cannot avoid ugly nesting, because
		return and goto are out of scope
		*/

		/* check input */
		if( !SvOK(SvA) ){
			warn("addr_cmp: undef input (1)\n");
			RETVAL = &PL_sv_undef;
		}else if( !SvOK(SvB) ){
			warn("addr_cmp: undef input (2)\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* A: SV -> string */
			StrA = (char *) SvPV(SvA, len);
			/* A: string -> struct addr */
			if( addr_aton(StrA, &SadA) < 0 ){
				warn("addr_cmp: addr_aton: error (1)\n");
				RETVAL = &PL_sv_undef; 
			}else{
				/* B: SV -> string */
				StrB = (char *) SvPV(SvB, len);
				/* B: string -> struct addr */
				if( addr_aton(StrB, &SadB) < 0 ){
					warn("addr_cmp: addr_aton: error (2)\n");
					RETVAL = &PL_sv_undef; 
				}else{
					/* compute output */
					RETVAL = newSVnv((double) addr_cmp(&SadA, &SadB));
				}
			}
		}
	OUTPUT:
	RETVAL

SV *
addr_bcast(SvAd)
		SV *SvAd;
	PROTOTYPE: $
	CODE:
		char *StrAd;
		struct addr SadAd, SadBc;
		int len;

		/* check input */
		if( !SvOK(SvAd) ){
			warn("addr_bcast: undef input\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* address: SV -> string */
			StrAd = (char *) SvPV(SvAd, len);
			/* address: string -> struct addr */
			if( addr_aton(StrAd, &SadAd) < 0 ){
				warn("addr_bcast: addr_aton: error\n");
				RETVAL = &PL_sv_undef; 
			/* compute output */
			}else if( addr_bcast(&SadAd, &SadBc) < 0 ){
				warn("addr_bcast: error\n");
				RETVAL = &PL_sv_undef;	
			}else{
				/* broadcast: struct addr -> SV */
				if( (StrAd = addr_ntoa((struct addr *) &SadBc)) == NULL){
					warn("addr_bcast: addr_ntoa: error\n");
					RETVAL = &PL_sv_undef;
				}else{
					/* 0 means Perl does strlen() itself */
					RETVAL = newSVpv(StrAd, 0);
				}
			}
		}
	OUTPUT:
	RETVAL

SV *
addr_net(SvAd)
		SV *SvAd;
	PROTOTYPE: $
	CODE:
		char *StrAd;
		struct addr SadAd, SadBc;
		int len;

		/* check input */
		if( !SvOK(SvAd) ){
			warn("addr_net: undef input\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* address: SV -> string */
			StrAd = (char *) SvPV(SvAd, len);
			/* address: string -> struct addr */
			if( addr_aton(StrAd, &SadAd) < 0 ){
				warn("addr_net: addr_aton: error\n");
				RETVAL = &PL_sv_undef; 
			/* compute output */
			}else if( addr_net(&SadAd, &SadBc) < 0 ){
				warn("addr_net: error\n");
				RETVAL = &PL_sv_undef;	
			}else{
				/* broadcast: struct addr -> SV */
				if( (StrAd = addr_ntoa((struct addr *) &SadBc)) == NULL){
					warn("addr_net: addr_ntoa: error\n");
					RETVAL = &PL_sv_undef;
				}else{
					/* 0 means Perl does strlen() itself */
					RETVAL = newSVpv(StrAd, 0);
				}
			}
		}
	OUTPUT:
	RETVAL

SV*
arp_add(SvProtoAddr, SvHwAddr)
		SV *SvProtoAddr;
		SV *SvHwAddr;
	PROTOTYPE: $$
	CODE:
		arp_t *AtArp;
		struct arp_entry SarEntry;
		struct addr SadAddr;
		char *StrAddr;
		int len;

		/* check input */
		if( !SvOK(SvProtoAddr) ){
			warn("arp_add: undef input(1)\n");
			RETVAL = &PL_sv_undef;
		}else if( !SvOK(SvHwAddr) ){
			warn("arp_add: undef input(2)\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* open arp handler */
			if( (AtArp = arp_open()) == NULL ){
				warn("arp_add: arp_open: error\n");
				RETVAL = &PL_sv_undef;
			}else{

				/* protocol address: SV -> string  */
				StrAddr = (char *) SvPV(SvProtoAddr, len);

				/* protocol address: string -> struct addr */
				if( addr_aton(StrAddr, &SadAddr) < 0 ){
					warn("arp_add: addr_aton: error (1)\n");
					RETVAL = &PL_sv_undef;
				}else{
					/* protocol address -> arp_entry */
					memcpy(&SarEntry.arp_pa, &SadAddr, sizeof(struct addr));

					/* hardware address: SV -> string  */
					StrAddr = (char *) SvPV(SvHwAddr, len);

					/* hardware address: string -> struct addr */
					if( addr_aton(StrAddr, &SadAddr) < 0 ){
						warn("arp_add: addr_aton: error (2)\n");
						RETVAL = &PL_sv_undef;
					}else{
						memcpy(&SarEntry.arp_ha, &SadAddr, sizeof(struct addr));

						/* add to ARP table */
						if( arp_add(AtArp, &SarEntry) < 0 ){
							warn("arp_add: error\n");
							RETVAL = &PL_sv_undef;
						}else{
							RETVAL = newSVnv(1);
						}
					}
				}

				/* close arp handler */
				arp_close(AtArp);
			}
		}
	OUTPUT:
	RETVAL

SV*
arp_delete(SvProtoAddr)
		SV *SvProtoAddr;
	PROTOTYPE: $
	CODE:
		arp_t *AtArp;
		struct arp_entry SarEntry;
		struct addr SadAddr;
		char *StrAddr;
		int len;

		/* check input */
		if( !SvOK(SvProtoAddr) ){
			warn("arp_delete: undef input\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* open arp handler */
			if( (AtArp = arp_open()) == NULL ){
				warn("arp_get: arp_open: error\n");
				RETVAL = &PL_sv_undef;
			}else{

				/* convert input to string */
				StrAddr = (char *) SvPV(SvProtoAddr, len);

				/* convert input to struct addr */
				if( addr_aton(StrAddr, &SadAddr) < 0 ){
					warn("arp_delete: addr_aton: error\n");
					RETVAL = &PL_sv_undef;
				}else{
					memcpy(&SarEntry.arp_pa, &SadAddr, sizeof(struct addr));

					/* resolve protocol address with arp */
					if( arp_delete(AtArp, &SarEntry) < 0 ){
						/* do not warn: a request for a nonexistant address is valid */
						RETVAL = &PL_sv_undef;
					}else{
						RETVAL = newSVnv(1);
					}

				}

				/* close arp handler */
				arp_close(AtArp);
			}
		}
	OUTPUT:
	RETVAL

SV*
arp_get(SvProtoAddr)
		SV *SvProtoAddr;
	PROTOTYPE: $
	CODE:
		arp_t *AtArp;
		struct arp_entry SarEntry;
		struct addr SadAddr;
		char *StrAddr;
		int len;

		/* check input */
		if( !SvOK(SvProtoAddr) ){
			warn("arp_get: undef input\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* open arp handler */
			if( (AtArp = arp_open()) == NULL ){
				warn("arp_get: arp_open: error\n");
				RETVAL = &PL_sv_undef;
			}else{

				/* convert input to string */
				StrAddr = (char *) SvPV(SvProtoAddr, len);

				/* convert input to struct addr */
				if( addr_aton(StrAddr, &SadAddr) < 0 ){
					warn("arp_get: addr_aton: error\n");
					RETVAL = &PL_sv_undef;
				}else{
					memcpy(&SarEntry.arp_pa, &SadAddr, sizeof(struct addr));

					/* resolve protocol address with arp */
					if( arp_get(AtArp, &SarEntry) < 0 ){
						/* do not warn: a request for a nonexistant address is valid */
						RETVAL = &PL_sv_undef;
					}else{

						/* convert output to string */
						if( (StrAddr = addr_ntoa( (struct addr *) &SarEntry.arp_ha)) == NULL){
							warn("arp_get: addr_ntoa: error\n");
							RETVAL = &PL_sv_undef;
						}else{
							/* 0 means Perl does strlen() itself */
							RETVAL = newSVpv(StrAddr, 0);
						}
					}
				}

				/* close arp handler */
				arp_close(AtArp);
			}
		}
	OUTPUT:
	RETVAL

HV *
intf_get(SvName)
		SV *SvName;
	PROTOTYPE: $
	CODE:
		HV *HvUndef;
		intf_t *ItIntf;
		struct intf_entry SieEntry;
		char *StrName;
		int len;

		/* prepare undefined hash */
		HvUndef = newHV();
		hv_undef(HvUndef);

		/* check input */
		if( !SvOK(SvName) ){
			warn("intf_get: undef input\n");
			RETVAL = HvUndef;
		}else{
			/* open intf handler */
			if( (ItIntf = intf_open()) == NULL ){
				warn("intf_get: intf_open: error\n");
				RETVAL = HvUndef;
			}else{
				/* name: SV -> string */
				StrName = (char *) SvPV(SvName, len);

				/* request interface */
				SieEntry.intf_len = sizeof(SieEntry);
				strncpy(SieEntry.intf_name, StrName, INTF_NAME_LEN);
				if( intf_get(ItIntf, &SieEntry) < 0 ){
					/* cannot warn, since the name may not exist */
					RETVAL = HvUndef;
				}else{
					RETVAL = intf2hash(&SieEntry);
				}

				/* close intf handler */
				intf_close(ItIntf);
			}
		}
	OUTPUT:
	RETVAL

HV *
intf_get_src(SvAddr)
		SV *SvAddr;
	PROTOTYPE: $
	CODE:
		HV *HvUndef;
		intf_t *ItIntf;
		struct intf_entry SieEntry;
		struct addr SaAddr;
		char *StrAddr;
		int len;

		/* prepare undefined hash */
		HvUndef = newHV();
		hv_undef(HvUndef);

		/* check input */
		if( !SvOK(SvAddr) ){
			warn("intf_get_src: undef input\n");
			RETVAL = HvUndef;
		}else{
			/* open intf handler */
			if( (ItIntf = intf_open()) == NULL ){
				warn("intf_get_src: intf_open: error\n");
				RETVAL = HvUndef;
			}else{
				/* addr: SV -> string */
				StrAddr = (char *) SvPV(SvAddr, len);

				/* addr: string -> struct addr */
				if( addr_aton(StrAddr, &SaAddr) < 0 ){
					warn("intf_get_src: addr_aton: error\n");
					RETVAL = HvUndef;
				}else{
					/* request interface */
					SieEntry.intf_len = sizeof(SieEntry);
					if( intf_get_src(ItIntf, &SieEntry, &SaAddr) < 0 ){
						/* cannot warn, since the name may not exist */
						RETVAL = HvUndef;
					}else{
						RETVAL = intf2hash(&SieEntry);
					}
				}

				/* close intf handler */
				intf_close(ItIntf);
			}
		}
	OUTPUT:
	RETVAL

HV *
intf_get_dst(SvAddr)
		SV *SvAddr;
	PROTOTYPE: $
	CODE:
		HV *HvUndef;
		intf_t *ItIntf;
		struct intf_entry SieEntry;
		struct addr SaAddr;
		char *StrAddr;
		int len;

		/* prepare undefined hash */
		HvUndef = newHV();
		hv_undef(HvUndef);

		/* check input */
		if( !SvOK(SvAddr) ){
			warn("intf_get_dst: undef input\n");
			RETVAL = HvUndef;
		}else{
			/* open intf handler */
			if( (ItIntf = intf_open()) == NULL ){
				warn("intf_get_dst: intf_open: error\n");
				RETVAL = HvUndef;
			}else{
				/* addr: SV -> string */
				StrAddr = (char *) SvPV(SvAddr, len);

				/* addr: string -> struct addr */
				if( addr_aton(StrAddr, &SaAddr) < 0 ){
					warn("intf_get_dst: addr_aton: error\n");
					RETVAL = HvUndef;
				}else{
					/* request interface */
					SieEntry.intf_len = sizeof(SieEntry);
					if( intf_get_dst(ItIntf, &SieEntry, &SaAddr) < 0 ){
						/* cannot warn, since the name may not exist */
						RETVAL = HvUndef;
					}else{
						RETVAL = intf2hash(&SieEntry);
					}
				}

				/* close intf handler */
				intf_close(ItIntf);
			}
		}
	OUTPUT:
	RETVAL

SV*
route_add(SvDstAddr, SvGwAddr)
		SV *SvDstAddr;
		SV *SvGwAddr;
	PROTOTYPE: $$
	CODE:
		route_t *RtRoute;
		struct route_entry SrtEntry;
		struct addr SadAddr;
		char *StrAddr;
		int len;

		/* check input */
		if( !SvOK(SvDstAddr) ){
			warn("route_add: undef input(1)\n");
			RETVAL = &PL_sv_undef;
		}else if( !SvOK(SvGwAddr) ){
			warn("route_add: undef input(2)\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* open route handler */
			if( (RtRoute = route_open()) == NULL ){
				warn("route_add: route_open: error\n");
				RETVAL = &PL_sv_undef;
			}else{

				/* destination address: SV -> string  */
				StrAddr = (char *) SvPV(SvDstAddr, len);

				/* destination address: string -> struct addr */
				if( addr_aton(StrAddr, &SadAddr) < 0 ){
					warn("route_add: addr_aton: error (1)\n");
					RETVAL = &PL_sv_undef;
				}else{
					/* destination address -> route_entry */
					memcpy(&SrtEntry.route_dst, &SadAddr, sizeof(struct addr));

					/* gateway address: SV -> string  */
					StrAddr = (char *) SvPV(SvGwAddr, len);

					/* gateway address: string -> struct addr */
					if( addr_aton(StrAddr, &SadAddr) < 0 ){
						warn("route_add: addr_aton: error (2)\n");
						RETVAL = &PL_sv_undef;
					}else{
						memcpy(&SrtEntry.route_gw, &SadAddr, sizeof(struct addr));

						/* add to route table */
						if( route_add(RtRoute, &SrtEntry) < 0 ){
							warn("route_add: error\n");
							RETVAL = &PL_sv_undef;
						}else{
							RETVAL = newSVnv(1);
						}
					}
				}

				/* close route handler */
				route_close(RtRoute);
			}
		}
	OUTPUT:
	RETVAL

SV*
route_delete(SvDstAddr)
		SV *SvDstAddr;
	PROTOTYPE: $
	CODE:
		route_t *RtRoute;
		struct route_entry SrtEntry;
		struct addr SadAddr;
		char *StrAddr;
		int len;

		/* check input */
		if( !SvOK(SvDstAddr) ){
			warn("route_delete: undef input\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* open route handler */
			if( (RtRoute = route_open()) == NULL ){
				warn("route_get: route_open: error\n");
				RETVAL = &PL_sv_undef;
			}else{

				/* convert input to string */
				StrAddr = (char *) SvPV(SvDstAddr, len);

				/* convert input to struct addr */
				if( addr_aton(StrAddr, &SadAddr) < 0 ){
					warn("route_delete: addr_aton: error\n");
					RETVAL = &PL_sv_undef;
				}else{
					memcpy(&SrtEntry.route_dst, &SadAddr, sizeof(struct addr));

					/* remove route */
					if( route_delete(RtRoute, &SrtEntry) < 0 ){
						/* do not warn: a request for a nonexistant address is valid */
						RETVAL = &PL_sv_undef;
					}else{
						RETVAL = newSVnv(1);
					}

				}

				/* close route handler */
				route_close(RtRoute);
			}
		}
	OUTPUT:
	RETVAL

SV*
route_get(SvDstAddr)
		SV *SvDstAddr;
	PROTOTYPE: $
	CODE:
		route_t *RtRoute;
		struct route_entry SrtEntry;
		struct addr SadAddr;
		char *StrAddr;
		int len;

		/* check input */
		if( !SvOK(SvDstAddr) ){
			warn("route_get: undef input\n");
			RETVAL = &PL_sv_undef;
		}else{
			/* open route handler */
			if( (RtRoute = route_open()) == NULL ){
				warn("route_get: route_open: error\n");
				RETVAL = &PL_sv_undef;
			}else{

				/* convert input to string */
				StrAddr = (char *) SvPV(SvDstAddr, len);

				/* convert input to struct addr */
				if( addr_aton(StrAddr, &SadAddr) < 0 ){
					warn("route_get: addr_aton: error\n");
					RETVAL = &PL_sv_undef;
				}else{
					memcpy(&SrtEntry.route_dst, &SadAddr, sizeof(struct addr));

					/* resolve protocol address with route */
					if( route_get(RtRoute, &SrtEntry) < 0 ){
						/* do not warn: a request for a nonexistant address is valid */
						RETVAL = &PL_sv_undef;
					}else{

						/* convert output to string */
						if( (StrAddr = addr_ntoa( (struct addr *) &SrtEntry.route_gw)) == NULL){
							warn("route_get: addr_ntoa: error\n");
							RETVAL = &PL_sv_undef;
						}else{
							/* 0 means Perl does strlen() itself */
							RETVAL = newSVpv(StrAddr, 0);
						}
					}
				}

				/* close route handler */
				route_close(RtRoute);
			}
		}
	OUTPUT:
	RETVAL

