"Let vim as a pdf reader
if exists("g:vim_pdf_loaded")
  finish
endif
let g:vim_pdf_loaded = 1

let s:pdf_cache = {}
autocmd BufReadPost *.pdf call s:loadpdf()
autocmd BufLeave *.pdf setlocal write
function s:loadpdf()
    if (line('$') < 2 || !strpart(getline(1), 1, 3) ==# "PDF")
        echo "vim-pdf: not a valid pdf file. stop converting..."
        return
    endif
    if !executable("pdftotext")
        echo "vim-pdf: pdftotext is not found. stop converting..."
        return
    endif

    execute "silent %delete"
    if has_key(s:pdf_cache, @%)
        execute "silent '[-1read ".s:pdf_cache[@%]
    else
        let pdf = escape(expand(@%), "'")
        let pdf_cache = escape(tempname(), "'")
        call system("pdftotext -nopgbrk -layout ".
                    \"'".pdf."' ".
                    \"'".pdf_cache."'")
        execute "silent '[-1read ".pdf_cache
        let s:pdf_cache[@%] = pdf_cache
    endif

    execute "silent setlocal nowrite"
    execute "silent set filetype=text"
endfunction
