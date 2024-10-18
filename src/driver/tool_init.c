/*
  License-Identifier: GPL
 
  Copyright (C) 2020 The Yambo Team
 
  Authors (see AUTHORS file for details): AM

*/

#include <stdlib.h>
#include <kind.h>
#include <string.h>
#include <stdio.h>
#include <wrapper.h>
#include <tool.h>
#include <driver.h>
#include <editor.h>

struct tool_struct tool_init( )
{
 tool_struct t;
 t=versions();
 t.editor=editor;
 /* t.editor="vim"; */
 t.tool=tool;
 t.desc=tool_desc;
 /*
   Projects
 */ 
 char *pj=NULL;
#if defined _YPP_ELPH || defined _ELPH
 pj="ph";
#endif
#if defined _YPP_RT || defined _RT
 pj="rt";
#endif
#if defined _YPP_SC || defined _SC
 pj="sc";
#endif
#if defined _YPP_NL || defined _NL
 pj="nl";
#endif
#if defined _YPP_FL || defined _FL
 pj="fl";
#endif
#if defined _QED
 pj="qed";
#endif
#if defined _SURF
 pj="surf";
#endif
#if defined _MODELS
 pj="models";
#endif

 if (pj!=NULL) {
  t.bin = malloc(strlen(tool) + strlen(pj) + 2);
  strcpy(t.bin,t.tool);
  t.pj=pj;
  strcat(t.bin,"_");
  strcat(t.bin,t.pj);
 }else{
  t.bin = malloc(strlen(tool) + 1);
  strcpy(t.bin,t.tool);
  pj="";
  t.pj=pj;
 }
 if (pj==NULL) pj=" ";
 sprintf(t.version_string,"%i.%i.%i Revision %i Hash %s",t.version,t.subversion,t.patchlevel,t.revision,t.hash);
 return(t);
};

