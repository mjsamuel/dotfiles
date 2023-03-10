; Inject into '@Component({ template: `...` })' as html
(decorator
  (call_expression
    function: (identifier) @function (#eq? @function "Component")
    (arguments
      (object
        (pair
          key: (property_identifier) @key (#eq? @key "template")
          ([ (template_string) @html (string) @html ]))))))

; Inject into '@Component({ styles `...` })' as css
(decorator
  (call_expression
    function: (identifier) @function (#eq? @function "Component")
    (arguments
      (object
        (pair
          key: (property_identifier) @key (#eq? @key "styles")
          (array
            ([ (template_string) @css (string) @css ])))))))

