(decorator
  (call_expression
    function: (identifier) @function (#eq? @function "Component")
    (arguments
      (object
        (pair
          key: (property_identifier) @key (#eq? @key "template")
          (template_string) @html
        )
      )
    )
  )
)

