"=============================================================================
" autocomplete.vim --- SpaceVim autocomplete layer
" Copyright (c) 2016-2019 Wang Shidong & Contributors
" Author: Wang Shidong < wsdjeg at 163.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

""
" @section autocomplete, autocomplete
" @parentsection layers
" @subsection code completion
" SpaceVim uses neocomplete as the default completion engine if vim has lua
" support. If there is no lua support, neocomplcache will be used for the
" completion engine. SpaceVim uses deoplete as the default completion engine
" for neovim. Deoplete requires neovim to be compiled with python support. For
" more information on python support, please read neovim's |provider-python|.
"
" SpaceVim includes YouCompleteMe, but it is disabled by default. To enable
" ycm, see |g:spacevim_enable_ycm|.
"
" @subsection snippet
" SpaceVim use neosnippet as the default snippet engine. The default snippets
" are provided by `Shougo/neosnippet-snippets`. For more information, please read
" |neosnippet|. Neosnippet support custom snippets, and the default snippets
" directory is `~/.SpaceVim/snippets/`. If `g:spacevim_force_global_config = 1`,
" SpaceVim will not append `./.SpaceVim/snippets` as default snippets directory.

function! SpaceVim#layers#autocomplete#plugins() abort
  let plugins = [
        \ ['honza/vim-snippets',          { 'on_event' : 'InsertEnter', 'loadconf_before' : 1}],
        \ ['Shougo/neco-syntax',          { 'on_event' : 'InsertEnter'}],
        \ ['Shougo/context_filetype.vim', { 'on_event' : 'InsertEnter'}],
        \ ['Shougo/neoinclude.vim',       { 'on_event' : 'InsertEnter'}],
        \ ['Shougo/neosnippet-snippets',  { 'merged' : 0}],
        \ ['Shougo/neopairs.vim',         { 'on_event' : 'InsertEnter'}],
        \ ]
  call add(plugins, ['deoplete-plugins/deoplete-dictionary',        { 'merged' : 0}])
  if g:spacevim_autocomplete_parens
    call add(plugins, ['jiangmiao/auto-pairs',        { 'merged' : 0}])
    let g:AutoPairsMapCR = 0
    let g:AutoPairsMultilineClose = 0
    let g:AutoPairsShortcutJump = 0
    inoremap <silent><m-n> <c-c>:call AutoPairsJump()<cr>a
  endif
  " snippet
  if g:spacevim_snippet_engine ==# 'neosnippet'
    call add(plugins,  ['Shougo/neosnippet.vim', { 'on_event' : 'InsertEnter',
          \ 'on_ft' : 'neosnippet',
          \ 'loadconf' : 1,
          \ 'on_cmd' : 'NeoSnippetEdit'}])
  elseif g:spacevim_snippet_engine ==# 'ultisnips'
    call add(plugins, ['SirVer/ultisnips',{ 'on_ft': ['snippets'], 'on_func': 'UltiSnips#ExpandSnippetOrJump', 'loadconf_before' : 1,
          \ 'merged' : 0}])
  endif
  if g:spacevim_autocomplete_method ==# 'ycm'
    call add(plugins, ['ycm-core/YouCompleteMe',            { 'build' : './install.py --clangd-completer', 'loadconf_before' : 1, 'merged' : 0}])
    inoremap <silent><cr> <c-r>=Ycm_and_AutoPair_Return()<cr>
  elseif g:spacevim_autocomplete_method ==# 'neocomplete'
    call add(plugins, ['Shougo/neocomplete', {
          \ 'on_event' : 'InsertEnter',
          \ 'loadconf' : 1,
          \ }])
  elseif g:spacevim_autocomplete_method ==# 'neocomplcache' "{{{
    call add(plugins, ['Shougo/neocomplcache.vim', {
          \ 'on_event' : 'InsertEnter',
          \ 'loadconf' : 1,
          \ }])
  elseif g:spacevim_autocomplete_method ==# 'coc'
    if executable('yarn')
      call add(plugins, ['neoclide/coc.nvim',  {'merged': 0, 'build': 'yarn install --frozen-lockfile'}])
    else
      call add(plugins, ['neoclide/coc.nvim',  {'merged': 0, 'rev': 'release'}])
    endif
  elseif g:spacevim_autocomplete_method ==# 'deoplete'
    call add(plugins, ['Shougo/deoplete.nvim', {
          \ 'on_event' : 'InsertEnter',
          \ 'loadconf' : 1,
          \ }])
    if !has('nvim')
      call add(plugins, ['SpaceVim/nvim-yarp',  {'merged': 0}])
      call add(plugins, ['SpaceVim/vim-hug-neovim-rpc',  {'merged': 0}])
    endif
  elseif g:spacevim_autocomplete_method ==# 'asyncomplete'
    call add(plugins, ['prabirshrestha/asyncomplete.vim', {
          \ 'loadconf' : 1,
          \ 'merged' : 0,
          \ }])
    call add(plugins, ['prabirshrestha/asyncomplete-buffer.vim', {
          \ 'loadconf' : 1,
          \ 'merged' : 0,
          \ }])
    call add(plugins, ['yami-beta/asyncomplete-omni.vim', {
          \ 'loadconf' : 1,
          \ 'merged' : 0,
          \ }])
  elseif g:spacevim_autocomplete_method ==# 'completor'
    call add(plugins, ['maralla/completor.vim', {
          \ 'loadconf' : 1,
          \ 'merged' : 0,
          \ }])
    if g:spacevim_snippet_engine ==# 'neosnippet'
      call add(plugins, ['maralla/completor-neosnippet', {
            \ 'loadconf' : 1,
            \ 'merged' : 0,
            \ }])
    endif
  endif
  if has('patch-7.4.774')
    call add(plugins, ['Shougo/echodoc.vim', {
          \ 'on_cmd' : ['EchoDocEnable', 'EchoDocDisable'],
          \ 'on_event': ['InsertEnter', 'CompleteDone'],
          \ 'loadconf_before' : 1,
          \ }])
  endif
  return plugins
endfunction

function! Ycm_and_AutoPair_Return()
  if expand('<cword>') == '{}' || expand('<cword>') == '()'
    return "\<CR>\<c-c>zz=ko"
  else
    exe 'return '. substitute(substitute(execute('imap <s-cr>'),'^.*<SNR>','<SNR>', ''),'S-CR','CR','')
  endif
endfunction


function! SpaceVim#layers#autocomplete#config() abort

  "mapping
  if s:tab_key_behavior ==# 'smart'
    if has('patch-7.4.774')
      imap <silent><expr><TAB> SpaceVim#mapping#tab()
      imap <silent><expr><S-TAB> SpaceVim#mapping#shift_tab()
      if g:spacevim_snippet_engine ==# 'neosnippet'
        smap <expr><TAB>
              \ neosnippet#expandable_or_jumpable() ?
              \ "\<Plug>(neosnippet_expand_or_jump)" :
              \ (complete_parameter#jumpable(1) ?
              \ "\<plug>(complete_parameter#goto_next_parameter)" :
              \ "\<TAB>")
      elseif g:spacevim_snippet_engine ==# 'ultisnips'
        snoremap <silent> <TAB>
              \ <ESC>:call UltiSnips#JumpForwards()<CR>
        snoremap <silent> <S-TAB>
              \ <ESC>:call UltiSnips#JumpBackwards()<CR>
      endif
    else
      call SpaceVim#logger#info('smart tab in autocomplete layer need patch 7.4.774')
    endif
  elseif s:tab_key_behavior ==# 'complete'
    inoremap <expr> <Tab>       pumvisible() ? "\<C-y>" : "\<C-n>"
  elseif s:tab_key_behavior ==# 'cycle'
    inoremap <expr> <Tab>       pumvisible() ? "\<Down>" : "\<Tab>"
    inoremap <expr> <S-Tab>       pumvisible() ? "\<Up>" : ""
  elseif s:tab_key_behavior ==# 'nil'
  endif
  if s:return_key_behavior ==# 'smart'
    imap <silent><expr><CR> SpaceVim#mapping#enter()
  elseif s:return_key_behavior ==# 'complete'
    imap <silent><expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
  elseif s:return_key_behavior ==# 'nil'
  endif

  inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
  inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
  inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
  " in origin vim or neovim Alt + / will insert a /, this should be disabled.
  let g:complete_parameter_use_ultisnips_mapping = 1
  if g:spacevim_snippet_engine ==# 'neosnippet'
    imap <expr> <M-/>
          \ neosnippet#expandable() ?
          \ "\<Plug>(neosnippet_expand)" : ""
  elseif g:spacevim_snippet_engine ==# 'ultisnips'
    inoremap <silent> <M-/> <C-C><right>:call UltiSnips#ExpandSnippetOrJump()<cr>
    vnoremap <silent> <M-/> <C-C>a
  endif

  let g:_spacevim_mappings_space.i = {'name' : '+Insertion'}
  if g:spacevim_snippet_engine ==# 'neosnippet'
    call SpaceVim#mapping#space#def('nnoremap', ['i', 's'], 'Unite neosnippet', 'insert snippets', 1)
  elseif g:spacevim_snippet_engine ==# 'ultisnips'
    call SpaceVim#mapping#space#def('nnoremap', ['i', 's'], 'Unite ultisnips', 'insert snippets', 1)
  endif
endfunction

let s:return_key_behavior = 'smart'
let s:tab_key_behavior = 'smart'
let s:key_sequence = 'nil'
let s:key_sequence_delay = 0.1
let g:_spacevim_autocomplete_delay = 50

function! SpaceVim#layers#autocomplete#set_variable(var) abort

  let s:return_key_behavior = get(a:var,
        \ 'auto_completion_return_key_behavior',
        \ get(a:var,
        \ 'auto-completion-return-key-behavior',
        \ s:return_key_behavior))
  let s:tab_key_behavior = get(a:var,
        \ 'auto_completion_tab_key_behavior',
        \ get(a:var,
        \ 'auto-completion-tab-key-behavior',
        \ s:tab_key_behavior))
  let s:key_sequence = get(a:var,
        \ 'auto_completion_complete_with_key_sequence',
        \ get(a:var,
        \ 'auto-completion-complete-with-key-sequence',
        \ s:key_sequence))
  let s:key_sequence_delay = get(a:var,
        \ 'auto_completion_complete_with_key_sequence_delay',
        \ get(a:var,
        \ 'auto-completion-complete-with-key-sequence-delay',
        \ s:key_sequence_delay))
  let g:_spacevim_autocomplete_delay = get(a:var,
        \ 'auto_completion_delay', 
        \ get(a:var, 'auto-completion-delay', 
        \ g:_spacevim_autocomplete_delay))

endfunction

function! SpaceVim#layers#autocomplete#get_options() abort

  return ['return_key_behavior',
        \ 'tab_key_behavior',
        \ 'auto_completion_complete_with_key_sequence',
        \ 'auto_completion_complete_with_key_sequence_delay']

endfunction

function! SpaceVim#layers#autocomplete#getprfile() abort



endfunction

" vim:set et sw=2 cc=80:
