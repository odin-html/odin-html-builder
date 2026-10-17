package a

accept :: proc(v: Value) -> Attr { return {"accept", v} }
accept_charset :: proc(v: Value) -> Attr { return {"accept-charset", v} }
accesskey :: proc(v: Value) -> Attr { return {"accesskey", v} }
action :: proc(v: Value) -> Attr { return {"action", v} }
allow :: proc(v: Value) -> Attr { return {"allow", v} }
allowfullscreen :: proc(v := true) -> Attr { return {"allowfullscreen", v} }
alt :: proc(v: Value) -> Attr { return {"alt", v} }
aria_activedescendant :: proc(v: Value) -> Attr { return {"aria-activedescendant", v} }
aria_atomic :: proc(v: bool) -> Attr { return {"aria-atomic", v ? "true" : "false"} }
aria_busy :: proc(v: bool) -> Attr { return {"aria-busy", v ? "true" : "false"} }
aria_checked :: proc(v: Value) -> Attr { return {"aria-checked", v} }
aria_colcount :: proc(v: Value) -> Attr { return {"aria-colcount", v} }
aria_colindex :: proc(v: Value) -> Attr { return {"aria-colindex", v} }
aria_colspan :: proc(v: Value) -> Attr { return {"aria-colspan", v} }
aria_controls :: proc(v: Value) -> Attr { return {"aria-controls", v} }
aria_current :: proc(v: Value) -> Attr { return {"aria-current", v} }
aria_describedby :: proc(v: Value) -> Attr { return {"aria-describedby", v} }
aria_details :: proc(v: Value) -> Attr { return {"aria-details", v} }
aria_disabled :: proc(v: bool) -> Attr { return {"aria-disabled", v ? "true" : "false"} }
aria_errormessage :: proc(v: Value) -> Attr { return {"aria-errormessage", v} }
aria_expanded :: proc(v: bool) -> Attr { return {"aria-expanded", v ? "true" : "false"} }
aria_flowto :: proc(v: Value) -> Attr { return {"aria-flowto", v} }
aria_haspopup :: proc(v: Value) -> Attr { return {"aria-haspopup", v} }
aria_hidden :: proc(v: bool) -> Attr { return {"aria-hidden", v ? "true" : "false"} }
aria_invalid :: proc(v: Value) -> Attr { return {"aria-invalid", v} }
aria_keyshortcuts :: proc(v: Value) -> Attr { return {"aria-keyshortcuts", v} }
aria_label :: proc(v: Value) -> Attr { return {"aria-label", v} }
aria_labelledby :: proc(v: Value) -> Attr { return {"aria-labelledby", v} }
aria_level :: proc(v: Value) -> Attr { return {"aria-level", v} }
aria_live :: proc(v: Value) -> Attr { return {"aria-live", v} }
aria_modal :: proc(v: bool) -> Attr { return {"aria-modal", v ? "true" : "false"} }
aria_multiselectable :: proc(v: bool) -> Attr { return {"aria-multiselectable", v ? "true" : "false"} }
aria_orientation :: proc(v: Value) -> Attr { return {"aria-orientation", v} }
aria_owns :: proc(v: Value) -> Attr { return {"aria-owns", v} }
aria_placeholder :: proc(v: Value) -> Attr { return {"aria-placeholder", v} }
aria_posinset :: proc(v: Value) -> Attr { return {"aria-posinset", v} }
aria_pressed :: proc(v: Value) -> Attr { return {"aria-pressed", v} }
aria_readonly :: proc(v: bool) -> Attr { return {"aria-readonly", v ? "true" : "false"} }
aria_required :: proc(v: bool) -> Attr { return {"aria-required", v ? "true" : "false"} }
aria_roledescription :: proc(v: Value) -> Attr { return {"aria-roledescription", v} }
aria_rowcount :: proc(v: Value) -> Attr { return {"aria-rowcount", v} }
aria_rowindex :: proc(v: Value) -> Attr { return {"aria-rowindex", v} }
aria_rowspan :: proc(v: Value) -> Attr { return {"aria-rowspan", v} }
aria_selected :: proc(v: bool) -> Attr { return {"aria-selected", v ? "true" : "false"} }
aria_setsize :: proc(v: Value) -> Attr { return {"aria-setsize", v} }
aria_sort :: proc(v: Value) -> Attr { return {"aria-sort", v} }
aria_valuemax :: proc(v: Value) -> Attr { return {"aria-valuemax", v} }
aria_valuemin :: proc(v: Value) -> Attr { return {"aria-valuemin", v} }
aria_valuenow :: proc(v: Value) -> Attr { return {"aria-valuenow", v} }
aria_valuetext :: proc(v: Value) -> Attr { return {"aria-valuetext", v} }
as :: proc(v: Value) -> Attr { return {"as", v} }
async :: proc(v := true) -> Attr { return {"async", v} }
attribute_name :: proc(v: Value) -> Attr { return {"attributeName", v} }
attribute_type :: proc(v: Value) -> Attr { return {"attributeType", v} }
autocapitalize :: proc(v: Value) -> Attr { return {"autocapitalize", v} }
autocomplete :: proc(v: Value) -> Attr { return {"autocomplete", v} }
autofocus :: proc(v := true) -> Attr { return {"autofocus", v} }
autoplay :: proc(v := true) -> Attr { return {"autoplay", v} }
base_frequency :: proc(v: Value) -> Attr { return {"baseFrequency", v} }
begin :: proc(v: Value) -> Attr { return {"begin", v} }
blocking :: proc(v: Value) -> Attr { return {"blocking", v} }
by :: proc(v: Value) -> Attr { return {"by", v} }
calc_mode :: proc(v: Value) -> Attr { return {"calcMode", v} }
charset :: proc(v: Value) -> Attr { return {"charset", v} }
checked :: proc(v := true) -> Attr { return {"checked", v} }
cite :: proc(v: Value) -> Attr { return {"cite", v} }
clip_path :: proc(v: Value) -> Attr { return {"clip-path", v} }
clip_path_units :: proc(v: Value) -> Attr { return {"clipPathUnits", v} }
clip_rule :: proc(v: Value) -> Attr { return {"clip-rule", v} }
color :: proc(v: Value) -> Attr { return {"color", v} }
color_interpolation :: proc(v: Value) -> Attr { return {"color-interpolation", v} }
color_interpolation_filters :: proc(v: Value) -> Attr { return {"color-interpolation-filters", v} }
cols :: proc(v: Value) -> Attr { return {"cols", v} }
colspan :: proc(v: Value) -> Attr { return {"colspan", v} }
content :: proc(v: Value) -> Attr { return {"content", v} }
contenteditable :: proc(v: bool) -> Attr { return {"contenteditable", v ? "true" : "false"} }
controls :: proc(v := true) -> Attr { return {"controls", v} }
coords :: proc(v: Value) -> Attr { return {"coords", v} }
crossorigin :: proc(v: Value) -> Attr { return {"crossorigin", v} }
cursor :: proc(v: Value) -> Attr { return {"cursor", v} }
cx :: proc(v: Value) -> Attr { return {"cx", v} }
cy :: proc(v: Value) -> Attr { return {"cy", v} }
d :: proc(v: Value) -> Attr { return {"d", v} }
datetime :: proc(v: Value) -> Attr { return {"datetime", v} }
decoding :: proc(v: Value) -> Attr { return {"decoding", v} }
default :: proc(v := true) -> Attr { return {"default", v} }
defer_ :: proc(v := true) -> Attr { return {"defer", v} }
diffuse_constant :: proc(v: Value) -> Attr { return {"diffuseConstant", v} }
dir :: proc(v: Value) -> Attr { return {"dir", v} }
direction :: proc(v: Value) -> Attr { return {"direction", v} }
dirname :: proc(v: Value) -> Attr { return {"dirname", v} }
disabled :: proc(v := true) -> Attr { return {"disabled", v} }
display :: proc(v: Value) -> Attr { return {"display", v} }
divisor :: proc(v: Value) -> Attr { return {"divisor", v} }
dominant_baseline :: proc(v: Value) -> Attr { return {"dominant-baseline", v} }
download :: proc(v: Value) -> Attr { return {"download", v} }
draggable :: proc(v: bool) -> Attr { return {"draggable", v ? "true" : "false"} }
dur :: proc(v: Value) -> Attr { return {"dur", v} }
dx :: proc(v: Value) -> Attr { return {"dx", v} }
dy :: proc(v: Value) -> Attr { return {"dy", v} }
edge_mode :: proc(v: Value) -> Attr { return {"edgeMode", v} }
elevation :: proc(v: Value) -> Attr { return {"elevation", v} }
enctype :: proc(v: Value) -> Attr { return {"enctype", v} }
end :: proc(v: Value) -> Attr { return {"end", v} }
enterkeyhint :: proc(v: Value) -> Attr { return {"enterkeyhint", v} }
exponent :: proc(v: Value) -> Attr { return {"exponent", v} }
fetchpriority :: proc(v: Value) -> Attr { return {"fetchpriority", v} }
fill :: proc(v: Value) -> Attr { return {"fill", v} }
fill_opacity :: proc(v: Value) -> Attr { return {"fill-opacity", v} }
fill_rule :: proc(v: Value) -> Attr { return {"fill-rule", v} }
filter :: proc(v: Value) -> Attr { return {"filter", v} }
filter_units :: proc(v: Value) -> Attr { return {"filterUnits", v} }
flood_color :: proc(v: Value) -> Attr { return {"flood-color", v} }
flood_opacity :: proc(v: Value) -> Attr { return {"flood-opacity", v} }
font_family :: proc(v: Value) -> Attr { return {"font-family", v} }
font_size :: proc(v: Value) -> Attr { return {"font-size", v} }
font_size_adjust :: proc(v: Value) -> Attr { return {"font-size-adjust", v} }
font_stretch :: proc(v: Value) -> Attr { return {"font-stretch", v} }
font_style :: proc(v: Value) -> Attr { return {"font-style", v} }
font_variant :: proc(v: Value) -> Attr { return {"font-variant", v} }
font_weight :: proc(v: Value) -> Attr { return {"font-weight", v} }
for_ :: proc(v: Value) -> Attr { return {"for", v} }
form :: proc(v: Value) -> Attr { return {"form", v} }
formaction :: proc(v: Value) -> Attr { return {"formaction", v} }
formenctype :: proc(v: Value) -> Attr { return {"formenctype", v} }
formmethod :: proc(v: Value) -> Attr { return {"formmethod", v} }
formnovalidate :: proc(v := true) -> Attr { return {"formnovalidate", v} }
formtarget :: proc(v: Value) -> Attr { return {"formtarget", v} }
fr :: proc(v: Value) -> Attr { return {"fr", v} }
from :: proc(v: Value) -> Attr { return {"from", v} }
fx :: proc(v: Value) -> Attr { return {"fx", v} }
fy :: proc(v: Value) -> Attr { return {"fy", v} }
gradient_transform :: proc(v: Value) -> Attr { return {"gradientTransform", v} }
gradient_units :: proc(v: Value) -> Attr { return {"gradientUnits", v} }
headers :: proc(v: Value) -> Attr { return {"headers", v} }
height :: proc(v: Value) -> Attr { return {"height", v} }
hidden :: proc(v := true) -> Attr { return {"hidden", v} }
high :: proc(v: Value) -> Attr { return {"high", v} }
href :: proc(v: Value) -> Attr { return {"href", v} }
hreflang :: proc(v: Value) -> Attr { return {"hreflang", v} }
http_equiv :: proc(v: Value) -> Attr { return {"http-equiv", v} }
id :: proc(v: Value) -> Attr { return {"id", v} }
imagesizes :: proc(v: Value) -> Attr { return {"imagesizes", v} }
imagesrcset :: proc(v: Value) -> Attr { return {"imagesrcset", v} }
in_ :: proc(v: Value) -> Attr { return {"in", v} }
in2 :: proc(v: Value) -> Attr { return {"in2", v} }
inert :: proc(v := true) -> Attr { return {"inert", v} }
inputmode :: proc(v: Value) -> Attr { return {"inputmode", v} }
integrity :: proc(v: Value) -> Attr { return {"integrity", v} }
intercept :: proc(v: Value) -> Attr { return {"intercept", v} }
interestfor :: proc(v: Value) -> Attr { return {"interestfor", v} }
is :: proc(v: Value) -> Attr { return {"is", v} }
ismap :: proc(v := true) -> Attr { return {"ismap", v} }
itemid :: proc(v: Value) -> Attr { return {"itemid", v} }
itemprop :: proc(v: Value) -> Attr { return {"itemprop", v} }
itemref :: proc(v: Value) -> Attr { return {"itemref", v} }
itemscope :: proc(v := true) -> Attr { return {"itemscope", v} }
itemtype :: proc(v: Value) -> Attr { return {"itemtype", v} }
k1 :: proc(v: Value) -> Attr { return {"k1", v} }
k2 :: proc(v: Value) -> Attr { return {"k2", v} }
k3 :: proc(v: Value) -> Attr { return {"k3", v} }
k4 :: proc(v: Value) -> Attr { return {"k4", v} }
kernel_matrix :: proc(v: Value) -> Attr { return {"kernelMatrix", v} }
kernel_unit_length :: proc(v: Value) -> Attr { return {"kernelUnitLength", v} }
key_points :: proc(v: Value) -> Attr { return {"keyPoints", v} }
key_splines :: proc(v: Value) -> Attr { return {"keySplines", v} }
key_times :: proc(v: Value) -> Attr { return {"keyTimes", v} }
kind :: proc(v: Value) -> Attr { return {"kind", v} }
label :: proc(v: Value) -> Attr { return {"label", v} }
lang :: proc(v: Value) -> Attr { return {"lang", v} }
length_adjust :: proc(v: Value) -> Attr { return {"lengthAdjust", v} }
letter_spacing :: proc(v: Value) -> Attr { return {"letter-spacing", v} }
lighting_color :: proc(v: Value) -> Attr { return {"lighting-color", v} }
limiting_cone_angle :: proc(v: Value) -> Attr { return {"limitingConeAngle", v} }
list :: proc(v: Value) -> Attr { return {"list", v} }
loading :: proc(v: Value) -> Attr { return {"loading", v} }
loop :: proc(v := true) -> Attr { return {"loop", v} }
low :: proc(v: Value) -> Attr { return {"low", v} }
marker_end :: proc(v: Value) -> Attr { return {"marker-end", v} }
marker_height :: proc(v: Value) -> Attr { return {"markerHeight", v} }
marker_mid :: proc(v: Value) -> Attr { return {"marker-mid", v} }
marker_start :: proc(v: Value) -> Attr { return {"marker-start", v} }
marker_units :: proc(v: Value) -> Attr { return {"markerUnits", v} }
marker_width :: proc(v: Value) -> Attr { return {"markerWidth", v} }
mask :: proc(v: Value) -> Attr { return {"mask", v} }
mask_content_units :: proc(v: Value) -> Attr { return {"maskContentUnits", v} }
mask_units :: proc(v: Value) -> Attr { return {"maskUnits", v} }
max :: proc(v: Value) -> Attr { return {"max", v} }
maxlength :: proc(v: Value) -> Attr { return {"maxlength", v} }
media :: proc(v: Value) -> Attr { return {"media", v} }
method :: proc(v: Value) -> Attr { return {"method", v} }
min :: proc(v: Value) -> Attr { return {"min", v} }
minlength :: proc(v: Value) -> Attr { return {"minlength", v} }
mode :: proc(v: Value) -> Attr { return {"mode", v} }
multiple :: proc(v := true) -> Attr { return {"multiple", v} }
muted :: proc(v := true) -> Attr { return {"muted", v} }
name :: proc(v: Value) -> Attr { return {"name", v} }
nomodule :: proc(v := true) -> Attr { return {"nomodule", v} }
nonce :: proc(v: Value) -> Attr { return {"nonce", v} }
novalidate :: proc(v := true) -> Attr { return {"novalidate", v} }
num_octaves :: proc(v: Value) -> Attr { return {"numOctaves", v} }
offset :: proc(v: Value) -> Attr { return {"offset", v} }
opacity :: proc(v: Value) -> Attr { return {"opacity", v} }
open :: proc(v := true) -> Attr { return {"open", v} }
operator :: proc(v: Value) -> Attr { return {"operator", v} }
optimum :: proc(v: Value) -> Attr { return {"optimum", v} }
order :: proc(v: Value) -> Attr { return {"order", v} }
orient :: proc(v: Value) -> Attr { return {"orient", v} }
origin :: proc(v: Value) -> Attr { return {"origin", v} }
overflow :: proc(v: Value) -> Attr { return {"overflow", v} }
paint_order :: proc(v: Value) -> Attr { return {"paint-order", v} }
path_length :: proc(v: Value) -> Attr { return {"pathLength", v} }
pattern :: proc(v: Value) -> Attr { return {"pattern", v} }
pattern_content_units :: proc(v: Value) -> Attr { return {"patternContentUnits", v} }
pattern_transform :: proc(v: Value) -> Attr { return {"patternTransform", v} }
pattern_units :: proc(v: Value) -> Attr { return {"patternUnits", v} }
ping :: proc(v: Value) -> Attr { return {"ping", v} }
placeholder :: proc(v: Value) -> Attr { return {"placeholder", v} }
playsinline :: proc(v := true) -> Attr { return {"playsinline", v} }
pointer_events :: proc(v: Value) -> Attr { return {"pointer-events", v} }
points :: proc(v: Value) -> Attr { return {"points", v} }
points_at_x :: proc(v: Value) -> Attr { return {"pointsAtX", v} }
points_at_y :: proc(v: Value) -> Attr { return {"pointsAtY", v} }
points_at_z :: proc(v: Value) -> Attr { return {"pointsAtZ", v} }
popover :: proc(v: Value) -> Attr { return {"popover", v} }
popovertarget :: proc(v: Value) -> Attr { return {"popovertarget", v} }
popovertargetaction :: proc(v: Value) -> Attr { return {"popovertargetaction", v} }
poster :: proc(v: Value) -> Attr { return {"poster", v} }
preload :: proc(v: Value) -> Attr { return {"preload", v} }
preserve_alpha :: proc(v: Value) -> Attr { return {"preserveAlpha", v} }
preserve_aspect_ratio :: proc(v: Value) -> Attr { return {"preserveAspectRatio", v} }
primitive_units :: proc(v: Value) -> Attr { return {"primitiveUnits", v} }
r :: proc(v: Value) -> Attr { return {"r", v} }
radius :: proc(v: Value) -> Attr { return {"radius", v} }
readonly :: proc(v := true) -> Attr { return {"readonly", v} }
ref_x :: proc(v: Value) -> Attr { return {"refX", v} }
ref_y :: proc(v: Value) -> Attr { return {"refY", v} }
referrerpolicy :: proc(v: Value) -> Attr { return {"referrerpolicy", v} }
rel :: proc(v: Value) -> Attr { return {"rel", v} }
repeat_count :: proc(v: Value) -> Attr { return {"repeatCount", v} }
repeat_dur :: proc(v: Value) -> Attr { return {"repeatDur", v} }
required :: proc(v := true) -> Attr { return {"required", v} }
required_extensions :: proc(v: Value) -> Attr { return {"requiredExtensions", v} }
restart :: proc(v: Value) -> Attr { return {"restart", v} }
result :: proc(v: Value) -> Attr { return {"result", v} }
reversed :: proc(v := true) -> Attr { return {"reversed", v} }
role :: proc(v: Value) -> Attr { return {"role", v} }
rotate :: proc(v: Value) -> Attr { return {"rotate", v} }
rows :: proc(v: Value) -> Attr { return {"rows", v} }
rowspan :: proc(v: Value) -> Attr { return {"rowspan", v} }
rx :: proc(v: Value) -> Attr { return {"rx", v} }
ry :: proc(v: Value) -> Attr { return {"ry", v} }
sandbox :: proc(v: Value) -> Attr { return {"sandbox", v} }
scale :: proc(v: Value) -> Attr { return {"scale", v} }
scope :: proc(v: Value) -> Attr { return {"scope", v} }
seed :: proc(v: Value) -> Attr { return {"seed", v} }
selected :: proc(v := true) -> Attr { return {"selected", v} }
shape :: proc(v: Value) -> Attr { return {"shape", v} }
shape_rendering :: proc(v: Value) -> Attr { return {"shape-rendering", v} }
side :: proc(v: Value) -> Attr { return {"side", v} }
size :: proc(v: Value) -> Attr { return {"size", v} }
sizes :: proc(v: Value) -> Attr { return {"sizes", v} }
slope :: proc(v: Value) -> Attr { return {"slope", v} }
slot :: proc(v: Value) -> Attr { return {"slot", v} }
spacing :: proc(v: Value) -> Attr { return {"spacing", v} }
span :: proc(v: Value) -> Attr { return {"span", v} }
specular_constant :: proc(v: Value) -> Attr { return {"specularConstant", v} }
specular_exponent :: proc(v: Value) -> Attr { return {"specularExponent", v} }
spellcheck :: proc(v: bool) -> Attr { return {"spellcheck", v ? "true" : "false"} }
spread_method :: proc(v: Value) -> Attr { return {"spreadMethod", v} }
src :: proc(v: Value) -> Attr { return {"src", v} }
srcdoc :: proc(v: Value) -> Attr { return {"srcdoc", v} }
srclang :: proc(v: Value) -> Attr { return {"srclang", v} }
srcset :: proc(v: Value) -> Attr { return {"srcset", v} }
start :: proc(v: Value) -> Attr { return {"start", v} }
start_offset :: proc(v: Value) -> Attr { return {"startOffset", v} }
std_deviation :: proc(v: Value) -> Attr { return {"stdDeviation", v} }
step :: proc(v: Value) -> Attr { return {"step", v} }
stitch_tiles :: proc(v: Value) -> Attr { return {"stitchTiles", v} }
stop_color :: proc(v: Value) -> Attr { return {"stop-color", v} }
stop_opacity :: proc(v: Value) -> Attr { return {"stop-opacity", v} }
stroke :: proc(v: Value) -> Attr { return {"stroke", v} }
stroke_dasharray :: proc(v: Value) -> Attr { return {"stroke-dasharray", v} }
stroke_dashoffset :: proc(v: Value) -> Attr { return {"stroke-dashoffset", v} }
stroke_linecap :: proc(v: Value) -> Attr { return {"stroke-linecap", v} }
stroke_linejoin :: proc(v: Value) -> Attr { return {"stroke-linejoin", v} }
stroke_miterlimit :: proc(v: Value) -> Attr { return {"stroke-miterlimit", v} }
stroke_opacity :: proc(v: Value) -> Attr { return {"stroke-opacity", v} }
stroke_width :: proc(v: Value) -> Attr { return {"stroke-width", v} }
style :: proc(v: Value) -> Attr { return {"style", v} }
surface_scale :: proc(v: Value) -> Attr { return {"surfaceScale", v} }
system_language :: proc(v: Value) -> Attr { return {"systemLanguage", v} }
tabindex :: proc(v: Value) -> Attr { return {"tabindex", v} }
table_values :: proc(v: Value) -> Attr { return {"tableValues", v} }
target :: proc(v: Value) -> Attr { return {"target", v} }
target_x :: proc(v: Value) -> Attr { return {"targetX", v} }
target_y :: proc(v: Value) -> Attr { return {"targetY", v} }
text_anchor :: proc(v: Value) -> Attr { return {"text-anchor", v} }
text_decoration :: proc(v: Value) -> Attr { return {"text-decoration", v} }
text_length :: proc(v: Value) -> Attr { return {"textLength", v} }
text_rendering :: proc(v: Value) -> Attr { return {"text-rendering", v} }
title :: proc(v: Value) -> Attr { return {"title", v} }
to :: proc(v: Value) -> Attr { return {"to", v} }
transform :: proc(v: Value) -> Attr { return {"transform", v} }
transform_origin :: proc(v: Value) -> Attr { return {"transform-origin", v} }
translate :: proc(v: Value) -> Attr { return {"translate", v} }
type :: proc(v: Value) -> Attr { return {"type", v} }
unicode_bidi :: proc(v: Value) -> Attr { return {"unicode-bidi", v} }
usemap :: proc(v: Value) -> Attr { return {"usemap", v} }
value :: proc(v: Value) -> Attr { return {"value", v} }
values :: proc(v: Value) -> Attr { return {"values", v} }
vector_effect :: proc(v: Value) -> Attr { return {"vector-effect", v} }
view_box :: proc(v: Value) -> Attr { return {"viewBox", v} }
visibility :: proc(v: Value) -> Attr { return {"visibility", v} }
width :: proc(v: Value) -> Attr { return {"width", v} }
word_spacing :: proc(v: Value) -> Attr { return {"word-spacing", v} }
wrap :: proc(v: Value) -> Attr { return {"wrap", v} }
writing_mode :: proc(v: Value) -> Attr { return {"writing-mode", v} }
writingsuggestions :: proc(v: Value) -> Attr { return {"writingsuggestions", v} }
x :: proc(v: Value) -> Attr { return {"x", v} }
x_channel_selector :: proc(v: Value) -> Attr { return {"xChannelSelector", v} }
x1 :: proc(v: Value) -> Attr { return {"x1", v} }
x2 :: proc(v: Value) -> Attr { return {"x2", v} }
xlink_href :: proc(v: Value) -> Attr { return {"xlink:href", v} }
xlink_title :: proc(v: Value) -> Attr { return {"xlink:title", v} }
xml_lang :: proc(v: Value) -> Attr { return {"xml:lang", v} }
xml_space :: proc(v: Value) -> Attr { return {"xml:space", v} }
xmlns :: proc(v: Value) -> Attr { return {"xmlns", v} }
xmlns_xlink :: proc(v: Value) -> Attr { return {"xmlns:xlink", v} }
y :: proc(v: Value) -> Attr { return {"y", v} }
y_channel_selector :: proc(v: Value) -> Attr { return {"yChannelSelector", v} }
y1 :: proc(v: Value) -> Attr { return {"y1", v} }
y2 :: proc(v: Value) -> Attr { return {"y2", v} }
z :: proc(v: Value) -> Attr { return {"z", v} }
zoom_and_pan :: proc(v: Value) -> Attr { return {"zoomAndPan", v} }
