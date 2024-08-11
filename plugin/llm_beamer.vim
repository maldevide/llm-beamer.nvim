if exists('g:loaded_llm_beamer') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! LLMBeamerActivate lua require('llm_beamer').handle_activation()
command! LLMBeamerInfo lua require('llm_beamer').create_or_focus_windows()
command! LLMBeamerHelp lua require('llm_beamer').show_help()
command! LLMBeamerSave lua require('llm_beamer').save_buffers()
command! LLMBeamerLoad lua require('llm_beamer').load_buffers()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_llm_beamer = 1
