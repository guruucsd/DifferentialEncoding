function lbl = guru_text2label(txt)
% Takes regular text, and outputs a matlab plot label-formatted string

  lbl = strrep(txt, '_', '__');
