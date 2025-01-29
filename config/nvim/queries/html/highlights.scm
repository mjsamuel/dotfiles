;; extends

((tag_name) @path_tag (#eq? @path_tag "path")
  (attribute
    (attribute_name) @att_name (#eq? @att_name "d")
    (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "󰇘")))
