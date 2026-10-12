" Obsidian vim keys, mirroring LazyVim (leader = Space)
set clipboard=unnamed

" move by visual line in wrapped paragraphs
nmap j gj
nmap k gk

unmap <Space>

" find / search
exmap switcher obcommand switcher:open
nmap <Space><Space> :switcher<CR>
nmap <Space>ff :switcher<CR>
exmap search obcommand global-search:open
nmap <Space>sg :search<CR>
exmap palette obcommand command-palette:open
nmap <Space>: :palette<CR>

" sidebar / outline
exmap explorer obcommand app:toggle-left-sidebar
nmap <Space>e :explorer<CR>
exmap outline obcommand outline:open
nmap <Space>o :outline<CR>
exmap backlinks obcommand backlink:open
nmap <Space>nb :backlinks<CR>

" splits and tabs
exmap splitv obcommand workspace:split-vertical
nmap <Space>sv :splitv<CR>
exmap splith obcommand workspace:split-horizontal
nmap <Space>sh :splith<CR>
exmap closetab obcommand workspace:close
nmap <Space>sq :closetab<CR>
nmap <Space>bd :closetab<CR>
exmap focusleft obcommand editor:focus-left
nmap <C-h> :focusleft<CR>
exmap focusbottom obcommand editor:focus-bottom
nmap <C-j> :focusbottom<CR>
exmap focustop obcommand editor:focus-top
nmap <C-k> :focustop<CR>
exmap focusright obcommand editor:focus-right
nmap <C-l> :focusright<CR>
exmap tabnext obcommand workspace:next-tab
nmap <Tab> :tabnext<CR>
exmap tabprev obcommand workspace:previous-tab
nmap <S-Tab> :tabprev<CR>

" links and history
exmap followlink obcommand editor:follow-link
nmap gd :followlink<CR>
exmap back obcommand app:go-back
nmap <C-o> :back<CR>
exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>

" notes
exmap daily obcommand daily-notes
nmap <Space>nd :daily<CR>
exmap togglecheck obcommand editor:toggle-checklist-status
nmap <Space>nx :togglecheck<CR>
exmap reading obcommand markdown:toggle-preview
nmap <Space>p :reading<CR>

" toggle Source / Live Preview (like LazyVim's <leader>um)
exmap togglesource obcommand editor:toggle-source
nmap <Space>um :togglesource<CR>
