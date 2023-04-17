// Copyright 2023 XXIV
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// EXAMPLES:
//
// pub fn main() void {
//     var json: [*c]const u8 = "{...}";
//     var len: usize = strlen(json);
//     var p: json_parser = json_parser{
//         .err = @bitCast(c_uint, @as(c_int, 0)),
//         .toks = null,
//         .cnt = 0,
//         .cap = 0,
//         .iter = null,
//         .stk = @import("std").mem.zeroes([512]json_iter),
//         .tok = @import("std").mem.zeroes(json_token),
//     };
//     while (json_load(&p, json, @bitCast(c_int, @truncate(c_uint, len))) != 0) {
//         p.toks = @ptrCast([*c]json_token, @alignCast(@import("std").meta.alignment(json_token), realloc(@ptrCast(?*anyopaque, p.toks), @bitCast(usize, @as(c_long, p.cap)) *% @sizeOf(json_token))));
//     }
//     var t0: [*c]json_token = json_query(p.toks, p.cnt, "map.entity[4].position");
//     _ = t0;
//     var size: usize = undefined;
//     var buffer: [64]u8 = undefined;
//     _ = json_query_string(@ptrCast([*c]u8, @alignCast(@import("std").meta.alignment(u8), &buffer)), @as(c_int, 64), @ptrCast([*c]c_int, @alignCast(@import("std").meta.alignment(c_int), &size)), p.toks, p.cnt, "map.entity[4].name");
//     var num: json_number = undefined;
//     _ = json_query_number(&num, p.toks, p.cnt, "map.soldier[2].position.x");
//     var type0: c_int = json_query_type(p.toks, p.cnt, "map.soldier[2]");
//     _ = type0;
//     var entity: [*c]json_token = json_query(p.toks, p.cnt, "map.entity[4]");
//     var position: [*c]json_token = json_query(entity, entity.*.sub, "position");
//     _ = position;
//     var rotation: [*c]json_token = json_query(entity, entity.*.sub, "rotation");
//     _ = rotation;
//     var elm: [*c]json_token = p.toks;
//     while (elm < (p.toks + @bitCast(usize, @intCast(isize, p.cnt)))) {
//         if (json_cmp(&elm[@intCast(c_uint, @as(c_int, 0))], "name") == @as(c_int, 0)) {
//             var ret: c_int = json_convert(&num, &elm[@intCast(c_uint, @as(c_int, 1))]);
//             _ = ret;
//         }
//         var elm_1: [*c]json_token = json_obj_next(elm_1);
//         _ = elm_1;
//     }
//     var m: [*c]json_token = json_query(p.toks, p.cnt, "map.soldier[2]");
//     var elm0: [*c]json_token = json_obj_begin(m);
//     {
//         var i: c_int = 0;
//         while ((i < m.*.children) and (elm0 != null)) : (i += 1) {
//             if (json_cmp(&elm0[@intCast(c_uint, @as(c_int, 0))], "a") == @as(c_int, 0)) {
//                 var ret: c_int = json_convert(&num, &elm0[@intCast(c_uint, @as(c_int, 1))]);
//                 _ = ret;
//             }
//             var elm_1: [*c]json_token = json_obj_next(elm0);
//             _ = elm_1;
//         }
//     }
//     var a: [*c]json_token = json_query(p.toks, p.cnt, "map.entities");
//     var ent: [*c]json_token = json_array_begin(a);
//     {
//         var i: c_int = 0;
//         while ((i < a.*.children) and (ent != null)) : (i += 1) {
//             var pos: [*c]json_token = json_query(ent, ent.*.sub, "position");
//             _ = pos;
//             ent = json_array_next(ent);
//         }
//     }
// }
pub const JSON_DELIMITER = '.';
pub const JSON_INITIAL_CAPACITY = @as(c_int, 256);
pub const JSON_MAX_DEPTH = @as(c_int, 512);
pub const json_number = f64;

pub const json_token_type = enum(c_uint) {
    JSON_NONE,
    JSON_OBJECT,
    JSON_ARRAY,
    JSON_NUMBER,
    JSON_STRING,
    JSON_TRUE,
    JSON_FALSE,
    JSON_NULL,
    JSON_MAX
};

pub const json_token = extern struct {
    str: [*c]const u8,
    type: json_token_type,
    len: c_int,
    children: c_int,
    sub: c_int,
};

pub const json_pair = extern struct {
    name: json_token,
    value: json_token,
};

pub const json_iter = extern struct {
    len: c_int,
    err: c_ushort,
    depth: c_ushort,
    go: [*c]const u8,
    src: [*c]const u8,
};

pub const json_status = enum(c_uint) {
    JSON_OK = 0,
    JSON_INVAL,
    JSON_OUT_OF_TOKEN,
    JSON_STACK_OVERFLOW,
    JSON_PARSING_ERROR
};

pub const json_parser = extern struct {
    err: json_status,
    toks: [*c]json_token,
    cnt: c_int,
    cap: c_int,
    iter: [*c]json_iter,
    stk: [JSON_MAX_DEPTH]json_iter,
    tok: json_token,
};

pub extern "C" fn json_begin(json: [*c]const u8, length: c_int) json_iter;
pub extern "C" fn json_read([*c]json_token, [*c]const json_iter) json_iter;
pub extern "C" fn json_parse([*c]json_pair, [*c]const json_iter) json_iter;
pub extern "C" fn json_cmp([*c]const json_token, [*c]const u8) c_int;
pub extern "C" fn json_cpy([*c]u8, c_int, [*c]const json_token) c_int;
pub extern "C" fn json_convert([*c]json_number, [*c]const json_token) c_int;
pub extern "C" fn json_num(json: [*c]const u8, length: c_int) c_int;
pub extern "C" fn json_load(p: [*c]json_parser, str: [*c]const u8, len: c_int) c_int;
pub extern "C" fn json_array_begin(tok: [*c]json_token) [*c]json_token;
pub extern "C" fn json_array_next(tok: [*c]json_token) [*c]json_token;
pub extern "C" fn json_obj_begin(tok: [*c]json_token) [*c]json_token;
pub extern "C" fn json_obj_next(toks: [*c]json_token) [*c]json_token;
pub extern "C" fn json_query(toks: [*c]json_token, count: c_int, path: [*c]const u8) [*c]json_token;
pub extern "C" fn json_query_number([*c]json_number, toks: [*c]json_token, count: c_int, path: [*c]const u8) c_int;
pub extern "C" fn json_query_string([*c]u8, max: c_int, size: [*c]c_int, [*c]json_token, count: c_int, path: [*c]const u8) c_int;
pub extern "C" fn json_query_type(toks: [*c]json_token, count: c_int, path: [*c]const u8) c_int;
