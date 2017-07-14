/*
 * Copyright (C) 2015 Swift Navigation Inc.
 * Contact: Fergus Noble <fergus@swift-nav.com>
 *
 * This source is subject to the license found in the file 'LICENSE' which must
 * be be distributed together with this source. All other rights reserved.
 *
 * THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
 */
 #include <stdio.h>
#include "../include/libsbp/common.h"
((*- for i in includes *))
#include "../include/libsbp/(((i)))"
((*- endfor *))

((*- for spec in package_specs *))
((= set some helpful variables for each package =))
((*- with *))
((*- set msgs = spec.definitions *)) 
((*- set name = spec.filepath[1] *))
((*- set description = spec.description *))
/*****************************************************************************
 * Automatically generated from (((name))).yaml 
 * with generate.py. Please do not hand edit!
 *****************************************************************************/

/** \defgroup (((pkg_name))) (((pkg_name|capitalize)))
 *
 * (((description|commentify)))
 * \{ */


((* for m in msgs *)) ((= Iterate over each message =))
((*- if m.desc *))
/** (((m.short_desc)))
 *
(((m.desc|commentify)))
 */
((*- endif *))

((*- if m.sbp_id *))
#define MSG_((('%04X'|format(m.sbp_id))))_TO_JSON (((m.identifier|convert)))_to_json_str
((*- endif *))

((*- if m.fields *))
((*- set in_ptr_type=(((m.identifier|convert))) *))
((*- else *))
((*- set in_ptr_type="void" *))
((*- endif *))

((* if m.sbp_id *))
((= The ID determines for me whether this is an SBP message or a sub structure =))
int (((m.identifier|convert)))_to_json_str( u16 sender_id, u16 msg_type, u8 msg_len, (((in_ptr_type))) * in, uint64_t max_len, char* out_str) {
  (void) sender_id;
  (void) msg_type;
  (void) msg_len;
((* else -*))
int (((m.identifier|convert)))_to_json_str( (((in_ptr_type))) * in, uint64_t max_len, char* out_str) {
((*- endif -*))

  (void) in;
  (void) out_str;
  (void) max_len;
  ((*- if (m|entirely_simple) and m.sbp_id *))
  return sprintf(out_str, (((m|mk_str_format_msg))), (((m|mk_arg_list_msg))));
  ((*- elif (m|entirely_simple) *))
  return sprintf(out_str, (((m|mk_str_format))), (((m|mk_arg_list))));
  ((* else *))
  char * const json_end = (char*) out_str + max_len; 
  char * json_bufp = (char*) out_str;
  (void) json_end;
  (void) json_bufp;

  ((*- if m.sbp_id *))
  json_bufp += snprintf(out_str, json_end - json_bufp, "{\"msg_type\": %u, \"sender\":%u, \"length\":%u", msg_type, sender_id, msg_len);
  ((*- endif *)) 

  ((*- for field in m.fields *))
    ((*- if (field.type_id|is_simple) *))
  json_bufp += snprintf(json_bufp, json_end - json_bufp, ", \"(((field.identifier)))\": (((field|get_format_str)))", in->(((field.identifier))));
    ((*- elif (field.type_id != "array") *))
  json_bufp += snprintf(json_bufp, json_end - json_bufp, ", \"(((field.identifier)))\":");
  json_bufp += (((field.type_id|convert)))_to_json_str(&in->(((field.identifier))), json_end - json_bufp, json_bufp);
    ((*- elif (field.type_id == "array" and field.options.get('size', None)) -*))
  json_bufp += snprintf(json_bufp, json_end - json_bufp, ", \"(((field.identifier)))\": {");
  for (int i=0; i < (((field.options.get('size').value))); i++) {
      ((* if (field|mk_id|is_simple) *))
    json_bufp += snprintf(json_bufp, json_end - json_bufp, "(((field|get_format_str)))", in->(((field.identifier)))[i]);
      ((* else -*))  
    json_bufp += (((field|mk_id)))_to_json_str(in->(((field.identifier))), json_end - json_bufp, json_bufp);
      ((* endif -*))
    }
    ((*- endif -*)) 
  ((* endfor *))
  json_bufp += snprintf(json_bufp, json_end - json_bufp, "}");
  return json_bufp - out_str;
  ((*- endif *))  
} 
((* endfor *))
((* endwith *))
((* endfor *))

int sbp2json(u16 sender_id, u16 msg_type, u8 msg_len,
                       u8 payload[], uint64_t max_len, char* out_str) {
switch(msg_type) { 
((*- for spec in package_specs *))
((*- with *))
((*- set msgs = spec.definitions *)) 
((*- set name = spec.filepath[1] *))
((*- set description = spec.description *))
((*-for m in msgs *))
((*- if m.fields *))
((*- set in_ptr_type=(((m.identifier|convert))) *))
((*- else *))
((*- set in_ptr_type="void" *))
((*- endif *))
  ((*- if m.sbp_id *))
  case (((m.sbp_id))):
    return (((m.identifier|convert)))_to_json_str(sender_id, msg_type, msg_len, ( (((in_ptr_type))) *) payload,
           max_len, out_str);
((*- endif *))
((*- endfor *))
((*- endwith *))
((*- endfor *))
  default:
    return 0;
  }
}