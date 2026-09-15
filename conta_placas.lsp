(vl-load-com)

;; ==========================================================
;; CP - Conta Placas (bloco NP) no Model Space, por categoria
;; Categorias, pelo padrão do rótulo (atributo do bloco NP):
;;   RE + número  -> A REMANEJAR   (ex: RE1, RE2)
;;   E + número   -> EXISTENTE     (ex: E1, E2)
;;   só número    -> A IMPLANTAR   (ex: 01, 02)
;;   qualquer outra coisa -> A RETIRAR (ex: A, B, C)
;; ==========================================================

;; Testa se uma string é toda composta só por dígitos (0-9)
(defun -CP:TudoDigitos (s / lst ok c)
  (setq lst (vl-string->list s) ok (> (strlen s) 0))
  (foreach c lst
    (if (not (and (>= c 48) (<= c 57))) (setq ok nil))
  )
  ok
)

;; Extrai o prefixo de letras (tudo antes dos dígitos finais)
(defun -CP:PrefixoLetras (s / n)
  (setq n (strlen s))
  (while (and (> n 0) (wcmatch (substr s n 1) "#"))
    (setq n (1- n))
  )
  (substr s 1 n)
)

;; Extrai o número no final da string (0 se não tiver)
(defun -CP:NumeroFinal (s / n digits)
  (setq n (strlen (-CP:PrefixoLetras s)))
  (setq digits (substr s (1+ n)))
  (if (> (strlen digits) 0) (atoi digits) 0)
)

;; Ordenação NATURAL: primeiro pelo prefixo de letras (E, RE, A, B...),
;; depois pelo número como número de verdade - assim E2 vem antes de E10.
(defun -CP:MenorNatural (a b / pa pb)
  (setq pa (-CP:PrefixoLetras (car a)) pb (-CP:PrefixoLetras (car b)))
  (if (= pa pb)
    (< (-CP:NumeroFinal (car a)) (-CP:NumeroFinal (car b)))
    (< pa pb)
  )
)

;; Classifica o rótulo numa das 4 categorias
(defun -CP:Categoria (rotulo / r)
  (setq r (strcase rotulo))
  (cond
    ((wcmatch r "RE#*") "A REMANEJAR")
    ((wcmatch r "E#*") "EXISTENTE")
    ((-CP:TudoDigitos rotulo) "A IMPLANTAR")
    (T "A RETIRAR")
  )
)

;; Lista, ordenado NATURALMENTE, os rótulos de labelCounts da categoriaAlvo
(defun -CP:ListarCategoria (labelCounts categoriaAlvo / ordenada entry)
  (setq ordenada (vl-sort labelCounts '-CP:MenorNatural))
  (foreach entry ordenada
    (if (= (-CP:Categoria (car entry)) categoriaAlvo)
      (princ (strcat "\n    " (car entry) ": " (itoa (cdr entry))))
    )
  )
)

(defun c:cp ( / doc msp item nomeEfetivo rotulo atts att labelCounts entry
                totExistente totRetirar totImplantar totRemanejar categoria total)

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq msp (vla-get-ModelSpace doc))

  (setq labelCounts nil)
  (setq totExistente 0 totRetirar 0 totImplantar 0 totRemanejar 0)

  (vlax-for item msp
    (if (= (vla-get-ObjectName item) "AcDbBlockReference")
      (progn
        ;; EffectiveName pega o nome real mesmo se for bloco dinâmico
        (setq nomeEfetivo
          (if (vlax-property-available-p item 'EffectiveName)
            (vla-get-EffectiveName item)
            (vla-get-Name item)
          )
        )
        (if (= (strcase nomeEfetivo) "NP")
          (if (= (vla-get-HasAttributes item) :vlax-true)
            (progn
              (setq atts (vlax-invoke item 'GetAttributes))
              (if atts
                (progn
                  (setq att (car atts)) ;; assume 1 atributo só nesse bloco
                  (setq rotulo (vl-string-trim " " (vla-get-TextString att)))

                  (if (> (strlen rotulo) 0)
                    (progn
                      ;; Acumula contagem por rótulo individual
                      (setq entry (assoc rotulo labelCounts))
                      (if entry
                        (setq labelCounts (subst (cons rotulo (1+ (cdr entry))) entry labelCounts))
                        (setq labelCounts (cons (cons rotulo 1) labelCounts))
                      )

                      ;; Acumula total por categoria
                      (setq categoria (-CP:Categoria rotulo))
                      (cond
                        ((= categoria "EXISTENTE") (setq totExistente (1+ totExistente)))
                        ((= categoria "A RETIRAR") (setq totRetirar (1+ totRetirar)))
                        ((= categoria "A IMPLANTAR") (setq totImplantar (1+ totImplantar)))
                        ((= categoria "A REMANEJAR") (setq totRemanejar (1+ totRemanejar)))
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )

  (setq total (+ totExistente totRetirar totImplantar totRemanejar))

  (if (= total 0)
    (princ "\n[AVISO] Nenhum bloco \"NP\" com atributo preenchido foi encontrado no Model Space.")
    (progn
      (princ "\n\n========== CONTAGEM DE PLACAS (bloco NP) ==========")

      (princ "\n\nEXISTENTES (E):")
      (-CP:ListarCategoria labelCounts "EXISTENTE")
      (princ (strcat "\n    >> TOTAL: " (itoa totExistente)))

      (princ "\n\nA RETIRAR:")
      (-CP:ListarCategoria labelCounts "A RETIRAR")
      (princ (strcat "\n    >> TOTAL: " (itoa totRetirar)))

      (princ "\n\nA IMPLANTAR:")
      (-CP:ListarCategoria labelCounts "A IMPLANTAR")
      (princ (strcat "\n    >> TOTAL: " (itoa totImplantar)))

      (princ "\n\nA REMANEJAR (RE):")
      (-CP:ListarCategoria labelCounts "A REMANEJAR")
      (princ (strcat "\n    >> TOTAL: " (itoa totRemanejar)))

      (princ (strcat "\n\n===================================================="))
      (princ (strcat "\nTOTAL GERAL DE PLACAS: " (itoa total)))
      (princ "\n====================================================")
    )
  )

  (princ)
)

(princ "\nComando CP (conta placas) carregado. Digite CP para contar as placas do projeto.")
(princ)
