-- Pandoc filter for the EPUB edition of The Agentic Crew.
-- Numbers chapters (level 1) and sections (level 2) the way the PDF does,
-- and tags part dividers, appendices, and front matter for styling.
local chap, sec = 0, 0
local in_appendix = false
local frontmatter = { ["Foreword"] = true, ["Preface to the Second Edition"] = true }

local function prefix(h, text, cls)
  h.content:insert(1, pandoc.Space())
  h.content:insert(1, pandoc.Span({ pandoc.Str(text) }, { class = cls }))
end

function Header(h)
  local t = pandoc.utils.stringify(h.content)
  if h.level == 1 then
    if t:match("^Part ") or t == "Appendices" then
      h.classes:insert("part")
      in_appendix = (t == "Appendices")
    elseif t:match("^Appendix ") then
      h.classes:insert("appendix")
      in_appendix = true
    elseif frontmatter[t] then
      h.classes:insert("frontmatter")
    else
      chap = chap + 1
      sec = 0
      h.classes:insert("chapter")
      prefix(h, tostring(chap), "chapnum")
    end
    return h
  elseif h.level == 2 and chap > 0 and not in_appendix then
    sec = sec + 1
    prefix(h, chap .. "." .. sec, "secnum")
    return h
  end
end
