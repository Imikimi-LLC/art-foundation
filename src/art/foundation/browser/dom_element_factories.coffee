supportLibs = [
  require "../standard_lib/string_case"
  require "../class_system/object_tree_factory"
]
###
dom_element_factories.coffee

This is a stand-alone version of Art.Foundation.Browser.Dom.createDomElementFactories.

It allows for Art.React-style creation of DOM elements.

Usage:

{Div, Span, B, Em} = DomElementFactories

mySharedTextStyle =
  style:
    fontSize: "16pt"
    color: "#444"
    fontFamily: "Times"

Div
  class: "foo"
  id:    "123"

Span
  class: "dude"
  "This is some really"
  B "bold"
  "text."
  "Also, here is some"
  Em "emphasized"
  "text."

Span mySharedTextStyle,
  internalHTML: "Or you can do <b>this</b> and <em>this</em>."

Div mySharedTextStyle,
  style:
    bottom:          0
    height:          "50px"
    left:            "100px"
    right:           "100px"
    position:        "fixed"
    backgroundColor: "white"
    textAlign:       "center"
  "Styles are easy, too."

###

#####################
# OBJECTS
#####################


#####################
# DomElementFactories
#####################
module.exports = class DomElementFactories
  for supportLib in supportLibs
    for k, v of supportLib
      @[k] = v

  @isString: isString = (obj) => typeof obj == "string"

  @mergeInto: mergeInto = (into, source) ->
    into ||= {}
    into[k] = v for k, v of source
    into

  ###
  IN: any combination of arrays and strings
  OUT: All element-names found in all strings are used to generate dom-element-factory-functions
    for elements with those names.
    The output is a plain Object where they keys are the upperCamelCase version of the element-names
    passed in. The values are the element-factories.

  ###
  @createDomElementFactories: (list...) =>
    @createObjectTreeFactories list, (nodeName, props, children) =>
      element = document.createElement nodeName
      for k, v of props
        switch k
          when "class" then element.className = v
          when "id" then element.id = v
          when "innerHTML" then element.innerHTML = v
          when "on"
            for eventType, eventListener of v
              element.addEventListener eventType, eventListener
          when "style"
            if isString v
              element.setAttribute k, v
            else
              {style} = element
              for styleKey, styleValue of v
                style[styleKey] = "" + styleValue

          else element.setAttribute k, v

      for child in children
        child = document.createTextNode child if isString child
        unless child instanceof Node
          message = "DomElementFactory:#{nodeName}: Child is not a string or instance of Node. Child: #{child}"
          console.error message, child
          throw new Error message
        element.appendChild child
      element
    , ''
    , (into, source) ->
      for k, v of source
        into[k] = if k == "style"
          mergeInto into[k], v
        else
          v

  @allElementNames: "
    A Abbr Acronym Address Applet Area Article Aside Audio B Base BaseFont Bdi Bdo
    Big BlockQuote Body Br Button Canvas Caption Center Cite Code Col ColGroup
    DataList Dd Del Details Dfn Dialog Dir Div Dl Dt Em Embed FieldSet FigCaption
    Figure Font Footer Form Frame FrameSet H1 Head Header Hr Html I IFrame Img Input
    Ins Kbd KeyGen Label Legend Li Link Main Map Mark Menu MenuItem Meta Meter Nav
    NoFrames NoScript Object Ol OptGroup Option Output P Param Pre Progress Q Rp Rt
    Ruby S Samp Script Section Select Small Source Span Strike Strong Style Sub
    Summary Sup Table TBody Td TextArea TFoot Th THead Time Title Tr Track Tt U Ul
    Var Video Wbr
    "

  @[k] = v for k, v of @createDomElementFactories @allElementNames
