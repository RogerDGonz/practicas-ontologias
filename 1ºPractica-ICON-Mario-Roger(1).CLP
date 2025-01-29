; Practica realizada por Gonzalez Liras, Mario y Gonzalez Niebla, Roger

; Plantillas Objeto-Atributo-Valor (OAV)
(deftemplate oav-u "Atributos univaluados"
	(slot objeto (type SYMBOL))
	(slot atributo (type SYMBOL))
	(slot valor)
)

(deftemplate oav-m "Atributos multivaluados"
	(slot objeto (type SYMBOL))
	(slot atributo (type SYMBOL))
	(slot valor)
)

; Regla para garantizar atributos univaluados (alta prioridad para consistencia de datos) EJERCICIO 1
(defrule garantiza-u
    (declare (salience 1000))
    ?a0 <- (oav-u (objeto ?x0) (atributo ?y0) (valor ?z0))
    ?a1 <- (oav-u (objeto ?x0) (atributo ?y0) (valor ?z1))
    (test (< (fact-index ?a0) (fact-index ?a1))) ; Prioriza el hecho mas antiguo
=>
    (retract ?a1) ; Elimina el hecho mas nuevo
)

; Paciente Procoro
(deffacts paciente-Procoro
	(oav-u (objeto Procoro) (atributo sexo) (valor hombre))
	(oav-u (objeto Procoro) (atributo edad) (valor 65))
	(oav-m (objeto Procoro) (atributo sintomas) (valor dolor-pecho))
	(oav-m (objeto Procoro) (atributo evidencia) (valor rumor-diastolico))
	(oav-m (objeto Procoro) (atributo evidencia) (valor masa-pulsante-en-el-abdomen))
	(oav-u (objeto Procoro) (atributo presion-sistolica) (valor 160))
	(oav-u (objeto Procoro) (atributo presion-diastolica) (valor 85))
	(oav-u (objeto Procoro) (atributo annos-fumando) (valor 4))
)

; Paciente Robustiana
(deffacts paciente-Robustiana
	(oav-u (objeto Robustiana) (atributo sexo) (valor mujer))
	(oav-u (objeto Robustiana) (atributo edad) (valor 75))
	(oav-m (objeto Robustiana) (atributo sintomas) (valor calambres-en-las-piernas-al-andar))
	(oav-m (objeto Robustiana) (atributo sintomas) (valor fiebre))
	(oav-u (objeto Robustiana) (atributo presion-sistolica) (valor 120))
	(oav-u (objeto Robustiana) (atributo presion-diastolica) (valor 70))
	(oav-u (objeto Robustiana) (atributo annos-fumando) (valor 16))
)

; Diagnostico de aneurisma en la arteria abdominal 
(defrule diagnostico-aneurisma
    (declare (salience 800))
    (oav-m (objeto ?paciente) (atributo sintomas) (valor dolor-pecho))
    (oav-m (objeto ?paciente) (atributo evidencia) (valor masa-pulsante-en-el-abdomen))
    (or (oav-m (objeto ?paciente) (atributo evidencia) (valor rumor-sistolico))
        (oav-m (objeto ?paciente) (atributo evidencia) (valor rumor-diastolico))) ; Rumor en el abdomen
=>
    (assert (oav-m (objeto ?paciente) (atributo diagnostico) (valor aneurisma-arteria-abdominal)))
)

; Diagnostico de regurgitacion aortica 
(defrule diagnostico-regurgitacion
    (declare (salience 700))
    (oav-u (objeto ?paciente) (atributo presion-sistolica) (valor ?ps & :(> ?ps 155)))
    (oav-u (objeto ?paciente) (atributo presion-diastolica) (valor ?pd & :(> ?pd 70)))
    (or (oav-m (objeto ?paciente) (atributo evidencia) (valor rumor-sistolico))
        (oav-m (objeto ?paciente) (atributo evidencia) (valor dilatacion-corazon)))
=>
    (assert (oav-m (objeto ?paciente) (atributo diagnostico) (valor regurgitacion-aortica)))
)

; Diagnostico de estenosis arterial 
(defrule diagnostico-estenosis
    (declare (salience 600))
    (oav-m (objeto ?paciente) (atributo sintomas) (valor calambres-en-las-piernas-al-andar))
=>
    (assert (oav-m (objeto ?paciente) (atributo diagnostico) (valor estenosis-arterial)))
)

; Diagnostico de arteriosclerosis
(defrule diagnostico-arteriosclerosis
    (declare (salience 500))
    (oav-m (objeto ?paciente) (atributo diagnostico) (valor estenosis-arterial))
    (or (oav-u (objeto ?paciente) (atributo edad) (valor ?edad & :(> ?edad 60)))
        (oav-u (objeto ?paciente) (atributo annos-fumando) (valor ?annos & :(> ?annos 15)))
        (oav-m (objeto ?paciente) (atributo evidencia) (valor obeso))) ; Grupo de riesgo
=>
    (assert (oav-m (objeto ?paciente) (atributo diagnostico) (valor arteriosclerosis)))
)

; Mostrar diagnostico del usuario si afecta al corazon
(defrule mostrar-diagnostico-corazon
    (declare (salience 101))
    (oav-m (objeto ?paciente) (atributo diagnostico) (valor regurgitacion-aortica))
=>
    (printout t "El/la paciente " ?paciente " ha sido diagnosticado con regurgitacion-aortica, enfermedad de tipo cardiovascular que afecta al corazón." crlf)
)

; Mostrar diagnostico del usuario si afecta a los vasos sanguineos
(defrule mostrar-diagnostico-vasos-sanguineos
    (declare (salience 100))
    (oav-m (objeto ?paciente) (atributo diagnostico) (valor ?diagnos))
    (test (neq ?diagnos regurgitacion-aortica)) ; Aquí se cerró correctamente la condición
=>
    (printout t "El/la paciente " ?paciente " ha sido diagnosticado con " ?diagnos ", enfermedad de tipo cardiovascular que afecta a los vasos sanguineos." crlf)
)

; Mostrar los pacientes que no tengan diagnosticos
(defrule no-diagnostico
    (declare (salience 1))
    (oav-u (objeto ?paciente) (atributo sexo) (valor ?sexo))
    (not (oav-m (objeto ?paciente) (atributo diagnostico) (valor ?diagnostico)))
=>
    (printout t "El/la paciente " ?paciente " no presenta diagnostico cardiovascular significativo." crlf)
)