;;;;;;;;;;;;;;;;;;---MIT License---;;;;;;;;;;;;;;;;;;;;;;;

;Copyright (c) 2025 Vittorio Nespeca

;Permission is hereby granted, free of charge, to any person obtaining a copy
;of this software and associated documentation files (the "Software"), to deal
;in the Software without restriction, including without limitation the rights
;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;copies of the Software, and to permit persons to whom the Software is
;furnished to do so, subject to the following conditions:

;The above copyright notice and this permission notice shall be included in all
;copies or substantial portions of the Software.

;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;SOFTWARE.

;;;;;;;;;;;;;;;;;;---Declaration of agents, variables and extensions---;;;;;;;;;;;;;;;;;;;;;;;

extensions [csv string]

globals [

  success-strategic?    ; true if the strategic choice made by the agent produced a more preferred organizational decision compared to the case in which the choice is sincere

  final-decision-done?  ; flags when the final decision has been made by the director and the simulation needs to be concluded

  final-decisions-i     ; represents one of the outcomes of the policy advice task i processed by the organization. This is a list containing 4 values [a b c d]:
                        ;    (a-i) Sincere decision S: decision made by strategic agent (S) if it was sincere
                        ;    (b-i) Org. Outcome with (a): organizational outcome when S chooses sincerely and thus selects (a)
                        ;    (c-i) Strategic decision S: actual strategic decision made by S
                        ;    (d-i) Org. Outcome with (c): organizational outcome wehn S chooses strategically and thus selects (c)
                        ;    (e-i) Strategic-outcome: tracks whether S in the context of the policy advice task i managed to improve organizational outcomes for itself by acting strategically,
                        ;    compared to the case in which S acted sincerely

  final-decisions       ; list containing sub-lists, where each sublist corresponds to the organizational outcomes of one policy advice task carried out by the organization.
                        ; one sublist = one policy advice task = one run of the model. Strcuture of a sublist for the task i:
                        ; [final-decision-i, strategic-outcome-i] = [a-i, b-i, c-i, d-i, e-i ]

  hammond-experiment-list  ; list contatining the experimental setup required to reproduce the single run experiment performed in Hammond's work (1986) to substantiate his propositions
  number-experiments       ; number of experiments associated with the considered proposition
  behavior-type            ; defines whether there is one agent that behaves
                              ; strategically -> behavior-type = "strategic"
                              ; or not -> behavior-type = "sincere"
                              ; strategic agent chooses according the option that leads to the most preferred predicted outcomes (assuming perfect knowledge on other agent's sincerity and preferences)
                              ; sincere agents choose based on their preferences: among the option available theychoose the one that is most preferred
                              ; Even when behavior type = "strategic", only one agent is "strategic", all others behave in a "sincere" manner
  jurisdiction-type        ; type of jurisdiction assigned in the experiment considered
  decision-rule-managers   ; this is the rule according to which magagers (those with subordinates, including the director) make decisions bassed on the input from their subordinates
                           ;   magement-by-exceptions = MBE. If all subordinates agree in their suggested options, then the managers chooses the agreed option. However, when there is disagreement, the manager disregards all suggestions and picks his/her preferred option (fromthe preferences list)
                           ;   pure-preferences = PP. Also in this case, agreement among subordinates means that the agreed option in chosen. However, when there is disagreement, the manager does not discard the suggestions, but rather the most preferred option is chosen among the suggestions.
  possible-plans           ; List of plans to be assessed by the organization. Each plan is a sublist is composed of decisions made concerning specific policy dimensions.
                           ; For instance, a plan can be the sublist [x1, y2, z3] where  x1, y2, and z3 are respectively decisions made for the dimensions X (e.g., economy), Y (e.g., military), and Z (e.g., diplomacy).

]

breed [bureaucrats bureaucrat]

bureaucrats-own [

  name                  ; name of the agent according to the experimental setup loaded from the CSV file (used only for Hammond experiments)
  structural-position   ; hierarchical position (0 is top)
  manager-id            ; who this bureaucrat reports to
  position-ag
  jurisdiction
  preferences
  strategic?
  decision-made
  hypothetical-decision-made
  sincere-decision-made-and-implications

]

directed-link-breed[structural-links structural-link]

structural-links-own [

  name-link                        ; link identifier composed of the name of the agent from which the links departs, followed by the name of the agent to which the link arrives
  who-made-me                      ; name of the agent who created the link (debugging purposes)
  shared-decision                  ; decision shared by the lower level agent to the higher level agent via the structural link
  hypothetical-shared-decision                 ; used for exploring potential organizational outcomes by strategic agents: hypothetical decision shared by the lower level agent to the higher level agent via the structural link
  sincere-decision-shared-and-implications     ; represents the sincere decision made by the strategic bureaucrat and shared with its superiors when the link is connected directly with the strategic bureaucrat.
                                               ; In other cases, it preresent the implications of the sincere decision of the bureaucrat from the hierarchicl levels below.
                                               ; It basically shows how the sincere decision propogates from the strategic agent to the director via the hierarchy, once such decision has been made.

]

breed [label-agents label-agent]

label-agents-own [

  associated-link-id              ; id of the link with which the label is associated
  associated-agent-id             ; id of the agent with which the label is associated

]



;;;;;;;;;;;;;;;;;;;;;;---Setup-Hammond-verification-experiments---;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to Load-Hammond-experiments ; setups verification experiments that reproduce exacly the examples introduced by Hammond to substantiate his propositions

  clear-all

  ; load CSV file of choice describing one of Hammond's experiments for the considered proposition
  let filename (word "../data/" Replicate-Hammond-experiment ".csv")
  set hammond-experiment-list csv:from-file filename
  set jurisdiction-type nospaces-string item 1 item 1 hammond-experiment-list
  set decision-rule-managers nospaces-string item 1 item 2 hammond-experiment-list
  set behavior-type nospaces-string item 1 item 5 hammond-experiment-list
  set number-experiments item 1 item 7 hammond-experiment-list

end

to-report nospaces-string [string]

  set string remove " " string

  report string

end



;;;;;;;;;;;;;;;;;;;---Go-Procedure-Hammond-verification-experiments---;;;;;;;;;;;;;;;;;;;;;;;;

to go-Hammond-experiments ; runs the experiments loaded via the Load-Hammond-experiment procedure

  ; loop to run all experiments and save their results
  let counter 0

  while [counter < number-experiments] [

    Print ""
    Print ""
    Print "___________________________________________________________________________"
    Print (word "START OF EXPERIMENT " counter)

    ; delete all turtles from the previous experiment
    clear-turtles

    ; set-up the experiment # counter
    set-experiment counter


    ;run-experiment
    set success-strategic? false
    task-processing

    ; check-outcomes and save them: print screen and save outputs in a table
    ; checking-outcomes

    ; export view and model output for comparison with Hammond's results
    let filename (word "../results/" Replicate-Hammond-experiment "_results_experiment_" counter ".png")
    export-view  filename
    set filename (word "../results/" Replicate-Hammond-experiment "_results_experiment_" counter ".txt")
    export-output filename

    set counter counter + 1

  ]

end

to set-experiment [counter]

  let current-experiment counter + 1

  ;; find information about the curret experiment

  ;get the policy plans available if working with policy dimensions
  if jurisdiction-type = "policy-dimensions" [

    let plans-start-position (position "start-possible-plans" (map first hammond-experiment-list)) + 1
    let plans-end-position (position "end-possible-plans" (map first hammond-experiment-list))
    let plans sublist hammond-experiment-list plans-start-position  plans-end-position

    set possible-plans []

    foreach plans [ plan ->
      let parsed-plan []
      let plan-number item 0 plan
      let decisions-plan parse-string-semicolon item 1 plan
      set possible-plans lput (list plan-number decisions-plan) possible-plans
    ]
  ]

  let target (word "Start-" current-experiment)
  let index-current-exp position target (map first hammond-experiment-list)

  let agents-names-list remove "" remove-item 0 item (index-current-exp + 1) hammond-experiment-list

  let agents-preferences-list remove "" remove-item 0 item (index-current-exp + 2) hammond-experiment-list

  let agents-position-list remove "" remove-item 0 item (index-current-exp + 3) hammond-experiment-list
  let agents-jurisdictions-list remove "" remove-item 0 item (index-current-exp + 4) hammond-experiment-list
  let agents-behaviour-list remove "" remove-item 0 item (index-current-exp + 5) hammond-experiment-list


  ;setup agent fixed characteristics
  foreach (map list agents-names-list agents-preferences-list) [ agent ->

    create-bureaucrats 1 [

      set name item 0 agent
      set preferences parse-string (item 1 agent)
      set shape "person"
      set size 1.5

    ]

  ]


  let agent-mutable-features (map list agents-names-list agents-position-list agents-jurisdictions-list agents-behaviour-list)
  print word "[name, position, jurisdiction, behavoiur] :" agent-mutable-features

  foreach agent-mutable-features [ agent ->

    let ag-name item 0 agent
    ask bureaucrats with [name = ag-name] [

      ;; extract name
      let mylist parse-string-semicolon item 1 agent
      set position-ag remove-item 0 mylist ; structural position (vertical, orizontal)
      set structural-position item 0 position-ag ; specifies hierarchical level, used in task processing for simplicity

      ;; in case the considered agent is the director
      let manager nobody
      set manager-id nobody
      let name-manager remove " " item 0 mylist

      ;; if the agent is not the director and actually has a manager
      if name-manager != "nobody"
      [
        set manager bureaucrats with [ name = name-manager]
        set manager-id item 0 [who] of manager
      ]

      set jurisdiction parse-string item 2 agent
      set strategic? (item 3 agent) = "strategic"
      if strategic? [
        set color orange
        set size size * 1.5
      ]
    ]

  ]

  layout-structure-hammond-experiment

end

to-report parse-string [s]

  if last s = " " [set s remove-item (length s - 1) s]
  if first s = " " [set s remove-item 0 s]

  while [position " " s != false] [ set s replace-item (position " " s) s ","]

  let l item 0 csv:from-string s

  report l

end

to-report parse-string-semicolon [s]
  let mylist remove " " s
  while [ position ";"  mylist != false ] [
    set mylist replace-item ( position ";" mylist)  mylist ","
  ]
  set mylist csv:from-row mylist
  report mylist
end

to layout-structure-hammond-experiment

  let max-position max [item 0 position-ag] of bureaucrats
  let num-levels max-position + 1
  let vertical-gap (max-pycor * 2) / (num-levels + 1)

  ask bureaucrats [

    ;; set position in the "world" based on bureaucrats' structural position
    let bureaucrats-at-my-level bureaucrats with [item 0 position-ag =  item 0 [position-ag] of myself ]
    let number-oriz-gaps-at-level 2 + max [item 1 position-ag] of bureaucrats-at-my-level
    let orizontal-gap-at-level max-pxcor * 2 / number-oriz-gaps-at-level
    let position-x min-pxcor + (item 1 position-ag + 1) * orizontal-gap-at-level
    let position-y max-pycor - (item 0 position-ag + 1) * vertical-gap
    setxy position-x position-y

    ;; create structural links
     if (manager-id != nobody) [
      create-structural-link-to turtle manager-id [
        set who-made-me myself
        set name-link (word [name] of end1 ", " [name] of end2)
      ]
    ]

  ]

  ;; Add labels to agents:

  ask bureaucrats [

    ;; Label - Preferences
    if jurisdiction-type != "policy-dimensions" [
      let my-label ""
      ; build the label string with each preference on a new line
      foreach preferences [pref -> set my-label word my-label (word pref "\n")]
      ; remove trailing newline
      if length my-label > 0 [set my-label substring my-label 0 (length my-label - 1)]
      hatch-label-agents 1 [
        setxy (xcor - 0.5) ycor
        set label my-label
        set size 0  ;; make the agent itself effectively invisible
      ]
    ]

    if jurisdiction-type = "specified-options" [
      ;; Label Jurisdictions
      if not member? "subs" jurisdiction [
        hatch-label-agents 1 [
          setxy (xcor + 5) (ycor - 0.5)
          set label [jurisdiction] of myself
          set size 0  ;; make the agent itself effectively invisible
        ]
      ]
    ]

    ;; Label Name
    hatch-label-agents 1 [
      setxy (xcor + 1.8) (ycor + 1.1)
      set label [name] of myself
      set size 0  ;; make the agent itself effectively invisible
    ]

    ;; Highlight stretegic agent
    if strategic? [
      hatch-label-agents 1 [
        set size 0
        setxy ([xcor] of myself + 4.5) ([ycor] of myself - 0.5)
        set label "Strategic"
      ]
    ]
  ]

end

;; Procedures for organizational task processing

to task-processing

  ; start processing the task for the lowest level
  let lowest-level max [structural-position] of bureaucrats

  let level lowest-level

  while [level >= 0] [

    let active-bureaucrats bureaucrats with [structural-position = level]

    ; if there is a strategic agent at this level, put it at the end of the list "active-bureaucrats", so that it makes its decision last when all other agents have made a decision
    ; this assumes that the strategic b. can perfectly forecast the decision of each agent as it knows their decision options and preferences
    set active-bureaucrats sort-on [ifelse-value strategic? [1] [0]] active-bureaucrats

    foreach active-bureaucrats [

      active-bureaucrat ->

      ask active-bureaucrat [

        ; choose suggested policy or option according to sincere or strategic behaviour
        let chosen-option choose-option-strategically-or-not level lowest-level
        if strategic? and (jurisdiction-type != "policy-dimensions") [ set chosen-option item 0 chosen-option ]

        ; the agent remembers chosen option (used by strategic agents to plan their choice)
        set decision-made chosen-option

        ; share the chosen option or plan with the manager
        ask my-out-structural-links [
          set shared-decision chosen-option

          ;; compute midpoint of the link
          let midpoint-x ([xcor] of end1 + [xcor] of end2) / 2
          let midpoint-y ([ycor] of end1 + [ycor] of end2) / 2

          ;; ask the bureaucrat (i.e., end1) to hatch the label-agent
          let name-link-start [name] of end1
          let name-link-end [name] of end2
          ask end1 [
            hatch-label-agents 1 [
              set associated-link-id (word name-link-start  ", " name-link-end)
              setxy midpoint-x midpoint-y
              set size 0
              ifelse jurisdiction-type = "policy-dimensions"
              [ set label item 0 chosen-option ]
              [ set label chosen-option ]
              set label-color color
            ]
          ]
        ]

        ; if final decision (the director is deciding), then save it in final decisions
        if item 0 position-ag = 0 [

          ;; Hatch a label-agent to display the final decision
          hatch-label-agents 1 [
            set size 0
            set associated-agent-id [who] of myself


            ifelse jurisdiction-type = "policy-dimensions"
            [
              if (behavior-type = "strategic") [set chosen-option item 1 chosen-option]
              let chosen-plan item 0 filter [x -> item 0 x = item 0 chosen-option] possible-plans
              set label (word "Chosen plan: "  item 0 chosen-plan ",\n" item 1 chosen-plan)
            ]
            [
              set label word "Final decision: " chosen-option
            ]
            set label-color Blue
            setxy ([xcor] of myself + 3) ([ycor] of myself + 4)

          ]

          ;set final-decisions chosen-option
          set final-decision-done? true

        ]
      ]
    ]

    set level level - 1

  ]

  ;; if the strategic behaviour was successful, modify the labels to show what changed from the sincere choice
  if behavior-type = "strategic" [display-strategic-impact]


end

to-report choose-option-strategically-or-not [level lowest-level] ; choses the preferred option by the bureaucrat and reports it. Considers strategic behaviour.
                                                                  ; -> agent procedure!

  let chosen-option "to be defined"

  ; if the strategic agent is choosing then explore scenarios and choose strategically
  ifelse strategic? [ set chosen-option explore-scenarios ]

  [ ; if not strategic, consider the hierarchical level

    ; if first level (operators), then just pick the preferred option (there is no input from lower level bureaucrats)
    ifelse level = lowest-level [ set chosen-option individual-task-processing-operators ]

    ; if above first level, use decision rules for managers
    [ set chosen-option individual-task-processing-managers false ] ; false because this is not making projections, but actual decisions

  ]

  report chosen-option

end

to-report explore-scenarios ; instead of directly deciding according to its preferences, the strategic bureaucrat explores all possible outcomes
                                ; of its available choices and chooses the option that leads to organizational outcomes that are the most preferred
                                ; -> agent procedure!



  print ""
  print "______________Strategic thinking starts here_________________________________________________________________"
  print ""
  print (word "*) Exploring-scenarios: I am the strategic agent " name ", exploring scenarios to decide strategically.")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; (1) GATHER AVAILABLE DECISION OPTIONS for the strategic bureaucrat ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  let options []
  ; find the sincere choice: this is the most preferred option with sincere behaviour
  let sincere-choice ""
  ;if bureaucrat at the lowest level is exploring scenarios,
  ifelse structural-position = max [structural-position] of bureaucrats
  [
    ;then the available options are the preferences
    set options preferences
    ; and the most preferred option is the first item in the list of preferences
    set sincere-choice item 0 preferences
  ]
  [;if not, need to consider the decisions made by subordinates

    ask my-in-structural-links [set options lput shared-decision options] ; Using shared decisions here as the hypothetical ones are made from the level of the strategic bureucrat up for more efficient computation

    ; if all subordinates agree and the decision rule is management by exceptions (MBE),
    ; then the agent must choose the option their subordinates agree on
    ; however, if the subordinates disagree, then the strategic agent can choose any option among its preferences
    if (decision-rule-managers = "management-by-exceptions") [
      set options remove-duplicates options
      if (length options > 1) [
        set options preferences
        set sincere-choice item 0 preferences
      ]
    ]

    ; in other cases, e.g. when decision rules are realted to preferences among plans or by spiecific sets of options as juridiction,
    ; the decision does not rely on MBE and it is always somewhat constrained by the decisions of the subordinates
    ; as such the options are not changed to the preferences of the manager who takes the decisions.
    if decision-rule-managers = "preferences-for-plans" [

      Print ""
      print (word "I am agent " name " finding the sincere choice")
      print (word "my preferences are " preferences)
      print (word "my options before processing are " options)

      ifelse length options > 1
      [print "HAVEN'T CODED THIS YET"]
      [
        ; get only the actual plans that are options
      set options item 0 map [x -> item 1 x ] options
      ]

      ;; Find and store sincere choice (most preferred option according to sincere behaviour). To do so here compare list of plans that are still available  and rank them based on the list of preferences
      let best-rank length preferences  ;; start with worst possible rank
      foreach options [
        option ->
        ; check at which rank the option outcome is among the preferences of the strategic agent
        let rank position (option) preferences
        if rank != false and rank < best-rank [
          set sincere-choice option
          set best-rank rank
        ]
      ]

    ]
  ]


  print ""
  print (word "my options after processing are " options " these are also the list of remaining plans")
  print (word "the sincere option found is " sincere-choice)


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; (2) PROJECT organizational OUTCOMES given the options from (1) ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  let projected-organizational-outcomes []

  let sincere-outcome ""

  foreach options [

    option ->
    print ""
    print ""
    print "==========================>"
    print word ">>>>  evaluating option " option
    print "==========================>"
    print ""

    ; If I am dealing with policy dimensions, I now need to process this option in terms of plans:
    ; The question is, if the chosen plan is "option", what are the remaining plans?


    ; if working with policy dimentions, setup the option as chosen plan so that it can be used by the relevant task processing procedures
    ; Chosen plan = [choice according to jurisdiction, [plans that remain available for choice by higher level managers]] -> e.g., [e1, [1 13 12 6])]
    let simple-option ""
    if jurisdiction-type = "policy-dimensions" [
      set simple-option option
      set option process-chosen-plan option options
    ]

    print word "   after processing the option is " option

    ;: calculate projected final decision by the organization when the strategic agents chooses this particular 'option'
    let organizational-outcome project option simple-option sincere-choice ; ----> project procedure

    let projected-option-outcome ""
    ifelse jurisdiction-type = "policy-dimensions" [
      let simple-organizational-outcome item 0 item 1 organizational-outcome
      set projected-option-outcome (list simple-option simple-organizational-outcome)
    ]
    [
      set projected-option-outcome (list option organizational-outcome)
    ]


    print (word "-----------------> if the option is " option ", organizational outcome is: " organizational-outcome)


    ;; Keep track of the outcome if the strategic Bureaucrat chooses sincerely (see code at step (1))
    let the-option ""
    ifelse jurisdiction-type = "policy-dimensions" [set the-option simple-option][set the-option option]
    if the-option = sincere-choice
    [; save the projection for the resulting organizational outcomes obtained thorugh sincere behaviour.
      set sincere-outcome item 1 projected-option-outcome
    ]

    ;; keep track of the outcome for each of the options considered
    set projected-organizational-outcomes lput projected-option-outcome projected-organizational-outcomes

  ]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; (3) CHOOSE the preferred OPTION, i.e., the one leading to a projected organizational OUTCOME that is the most preferred by the strategic agent ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  let preferred-strategy compare-options-outcomes-with-preferences projected-organizational-outcomes preferences

;  print ""
;  print ""
;  print (word "The projected organizational outcomes for all options are: " projected-organizational-outcomes)
;  print ""
;  print (word "--------------> My preferred option is: "  item 0 preferred-strategy ". leading to the outcome: " item 1 preferred-strategy)

  ; compare the sincere-outcome with the chosen strategic one
  set success-strategic? strategic-VS-sincere (item 1 preferred-strategy) sincere-outcome


  ; fill in final decisions-i : preferred option (sincere choice), outcome with sincere choice, strategic choice, outcome with strategic choice, success of strategic choice compared with sincere one
  set final-decisions-i (list sincere-choice sincere-outcome (item 0 preferred-strategy) (item 1 preferred-strategy) success-strategic?)

  ; if we are working with policy dimensions, adjust formatting of the preferred strategy
  if jurisdiction-type = "policy-dimensions" [

    ; the remaining plans are the options
    let remaining-plans options

    ; take the strategic choice leading to the preferred outcome
    let strategic-option-chosen item 0 preferred-strategy

    ; select decision (e.g., x2) in the preferred strategy according to the jursdiction of the manager (e.g., policy dimension X)
    let content-preferred-plan item 1 item 0 filter [x -> item 0 x = strategic-option-chosen] possible-plans
    let choice-jurisdiction item 0 filter [x -> member? (to-lower-case item 0 jurisdiction) x ] content-preferred-plan

    ; figure out the remaining plans based on the plans received as input and the choice that the strategic agent has made
      let possible-plans-bare map [x -> item 0 x] possible-plans
      set remaining-plans map [x -> item (position x possible-plans-bare) possible-plans ] remaining-plans
      let remaining-plans-update filter [x -> member? choice-jurisdiction item 1 x] remaining-plans

    ; consider that options should represent the remaining plans, which you will now restrict based on the latest choice by the strategic agent

    set preferred-strategy list choice-jurisdiction map [x -> item 0 x] remaining-plans-update

    ;set preferred-strategy process-chosen-plan item 0 preferred-strategy
    print (word "This is the input I am providing as a strategist to my manager via the structural link: " preferred-strategy)

  ]

  print ""
  print "______________Strategic thinking ends here_____________________________________________________________________________"
  print ""

  report preferred-strategy

end

to-report project [option simple-option sincere-choice]  ; calculates the projected organizational outcomes when the strategic agent hypothetically decides to choose the decision-option 'option'
                                           ; -> agent procedure!


  print word "--------------------------------------------> projecting: the option " option

  ; set option as the hypothetically selected decision by the bureaucrat
  set hypothetical-decision-made option
  ; share the hypothetically selected decision with the manager of the strategic bureacrat
  ask my-out-structural-links [ set hypothetical-shared-decision option ]

  ; if the option considered is the sincere one, then save this (used for diplaying changes from strategic behaviour)
  let considering-sincere-decision? false
  let the-option ""
  ifelse jurisdiction-type = "policy-dimensions" [set the-option simple-option][set the-option option]

  if the-option = sincere-choice [
    set sincere-decision-made-and-implications option
    ask my-out-structural-links [ set sincere-decision-shared-and-implications option ]
    set considering-sincere-decision? true
  ]

  ; the actual decisions made by other bureaucrats at the same level are also saved as their hypothetical decisions and shared via structural links to their managers
  ; this way all projections are computed via hypothetical decisions to avoid overlaps between actual and hypothetical (or strategic) decision making
  ; Note: we know these bureaucrats already decided because the strategic agent decides last (see "task-processing" procedure)
  let mylevel structural-position
  ask other bureaucrats with [structural-position = mylevel][
    set hypothetical-decision-made decision-made
    ask my-out-structural-links [ set hypothetical-shared-decision shared-decision ]
  ]

  let projection ""

  ; start processing the task at the level above the strategic bureaucrat
  let level mylevel - 1

  while [level >= 0] [

    ; select relevant bureaucrats that have a structural level equal or higher than that of the strategic bureaucrat (those below already made their decisions and those stay constant)
    ; what changes is 'option', i.e. the considered choice of the strategist for this projection scenario
    let relevant-bureaucrats sort bureaucrats with [structural-position = level]

    foreach relevant-bureaucrats [

      relevant-bureaucrat ->

      ask relevant-bureaucrat [

        let chosen-option individual-task-processing-managers true ; true = consider hypothetical decisions

        ; assign hypothetical decisions to agents
        set hypothetical-decision-made chosen-option

        ; share the hypothetical decision with the manager
        ask my-out-structural-links [ set hypothetical-shared-decision chosen-option ]

        ;; if the director made its final decision, then save this as the organizational outcome, i.e. as the 'projection'
        if structural-position = 0 [ set projection chosen-option ]

        ;; if we are projecting the sincere decision by the strategic bureaucrat, then save its impact on the decisions made by its superiors
        if considering-sincere-decision? [
          set sincere-decision-made-and-implications chosen-option
          ask my-out-structural-links [ set sincere-decision-shared-and-implications chosen-option ]
        ]

      ]

    ]

    set level level - 1

  ]

  report projection

end

to-report compare-options-outcomes-with-preferences [available-options-outcomes provided-preferences]

  print ""
  print "Finalizing strategic reasoning:"
  print ""
  print (word "I am agent " name ", comparing the options-outcomes " available-options-outcomes " with my preferences " provided-preferences)

  let best-option-outcome []
  let best-rank length provided-preferences  ;; start with worst possible rank

  foreach available-options-outcomes [
    option-outcome ->
    ; check at which rank the option outcome is among the preferences of the strategic agent
    let rank position (item 1 option-outcome) provided-preferences
    if rank != false and rank < best-rank [
      set best-option-outcome option-outcome
      set best-rank rank
    ]
  ]

  print (word "The best options is " best-option-outcome)

  report best-option-outcome

end

to-report strategic-VS-sincere [ strategic-outcome sincere-outcome ]

  let strategic-worked? false

  ; rank outcomes based on preferences
  let rank-strategic position strategic-outcome preferences
  let rank-sincere position sincere-outcome preferences

  print (word "The strategic outcome was: " strategic-outcome ", with a rank " rank-strategic " whereas the sincere outcome was: " sincere-outcome ", with a rank " rank-sincere )
  print word "my preferences are: " preferences

  ; if strategic outcome is preferred compared to the sincere outcome, then being strategic worked
  ifelse rank-strategic < rank-sincere
  [
    set strategic-worked? true
  ]
  [
    if rank-strategic = rank-sincere [set strategic-worked? "neutral"]
  ]

  print word "Did the strategic behaviour help to achieve a more desireable outcome? " strategic-worked?

  report strategic-worked?

end

to-report individual-task-processing-operators

  let operator-decision ""

  ; depending on the type of jurisdictions
  ifelse jurisdiction-type = "full-sets-of-options"
  [
    set operator-decision item 0 preferences
  ]
  [
    ifelse jurisdiction-type = "policy-dimensions"

    [
      ; pick the preferred plan among the preferences (e.g., 12 (w1, x2, y1, z1))
      let chosen-plan item 0 preferences
      let possible-plans-plain-formatting map [x -> item 0 x ] possible-plans
      let info-passed-on process-chosen-plan chosen-plan possible-plans-plain-formatting
      set operator-decision info-passed-on

      print (word "I am the operator agent " name)
      print (word "I am picking non- strategically based on my preferences " preferences )
      print (word "Choosing the most preferred plan " chosen-plan)
      print (word "Passing on my choice and the remaining plans " info-passed-on)

    ]

    [
      ifelse jurisdiction-type = "specified-options"
      [
        ; make a list containing the ranking in the preferences of the specific jurisdiction list
        let positions map [ x -> (list (position x preferences) x) ] jurisdiction
        ; pick the jurisdiction that has the highest ranking
        set operator-decision item 1 first sort-by [ [a b] -> (first a) < (first b) ] positions
      ]
      [
        print "The chosen jurisdiction type does not match the availble options. Procedure: individual-task-processing-operators"
      ]
    ]

  ]

  report operator-decision

end

to-report process-chosen-plan [chosen-plan plans-still-available] ; takes a chosen plan, calculates the remaining plans among which the superiors chan choose after that choice is made, formats in the correct way the input for supervisors

  ;print "______________________"
  ;print (word "I am agent" name ", processing the chosen plan " chosen-plan ". Considering that the plans still available are " plans-still-available)


  ; given a chosen plan extract its content
  let plans-plain map [x -> item 0 x] possible-plans

  let chosen-plan-content (item (position chosen-plan plans-plain) possible-plans)
  set chosen-plan-content item 0 remove first chosen-plan-content chosen-plan-content

  ; extract choice associated with jurisdiction (e.g., if jurisdiction is Y, then the choice is y1)
  let choice-jurisdiction item 0 filter [x -> member? to-lower-case (item 0 jurisdiction) x ] chosen-plan-content

  ; derive ensable of plans that comply with the choice (e.g., all the plans that contain y1 as a choice among the [plans that are still available)
  let plans-still-available-complete filter [x -> member? (item 0 x) plans-still-available] possible-plans

  let plans-compatible-with-choice filter [x -> member? choice-jurisdiction (item 1 x)] plans-still-available-complete

  ; this is the final choice passed on to superiors
  let polished-decision-plan list choice-jurisdiction map [x -> item 0 x] plans-compatible-with-choice

;  print (word "My jurisdiction is: " jurisdiction)
;  print word "My preferences are " preferences
;  print word "the plan I choose is " (item (position chosen-plan (map [x -> item 0 x] possible-plans)) possible-plans)
;  print word "My choice according to my jurisdiction is " choice-jurisdiction
;  print word "The plans that are compatible with my choice are: " plans-compatible-with-choice
;  print word "My final choice is " polished-decision-plan

  report polished-decision-plan

end

to-report to-lower-case [txt]
  let upper-letters "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let lower-letters "abcdefghijklmnopqrstuvwxyz"
  let result ""
  let n length txt

  foreach (n-values n [ i -> i ]) [ i ->
    let c item i txt
    if member? c upper-letters [
      set c item (position c upper-letters) lower-letters
    ]
    set result word result c
  ]

  report result
end

to-report individual-task-processing-managers [projection?]  ; takes the options selected by the subordinates and makes a decision through the manager's decision rules
                                                             ; when projection? = true it considers the subordinates' hypothetical decisions rather than their actual decisions
                                                             ; -> agent procedure!

  let manager-decision ""

  ;; gather decisions made by my subordinates
  let inputs []

  ; if it is a projection done by strategic bureaucrats
  ifelse projection?
  ; use the hypothetical decisions shared via the links
  [ask my-in-structural-links [set inputs lput hypothetical-shared-decision inputs]]
  ; if not, use the actual decisions shared via the links
  [ask my-in-structural-links [ set inputs lput shared-decision inputs]]


  ifelse decision-rule-managers = "preferences-for-plans"
  [

    if not projection? [
      print "___"
      print ""
      print (word "I am agent " name ", processing the inputs " inputs )
    ]

    ; if the considered manager gets inputs from more than one subordinate, calculate intersection among plans suggested by the subordinates
    let remaining-plans ""
    ifelse length inputs > 1 [
      set inputs map [x -> item 1 x] inputs
      set remaining-plans common-elements-lists inputs
    ]
    [
      set remaining-plans item 1 item 0 inputs
    ]

    ifelse length remaining-plans > 1 [

      ; among these plans chose the preferred one by the manager
      let ranked-plans map [x -> (list (position x preferences) x) ] remaining-plans
      let preferred-plan item 1 item 0 sort-by [[a b] -> item 0 a < item 0 b ] ranked-plans


      ; if the considered manager has a jurisdiction assigned

      ; select decision (e.g., x2) in the preferred plan according to the jursdiction of the manager (e.g., policy dimension X)
      let content-preferred-plan item 1 item 0 filter [x -> item 0 x = preferred-plan] possible-plans
      let choice-jurisdiction item 0 filter [x -> member? (to-lower-case item 0 jurisdiction) x ] content-preferred-plan


      ; filter remaining plans that comply with the choice of the manager
      let possible-plans-bare map [x -> item 0 x] possible-plans
      set remaining-plans map [x -> item (position x possible-plans-bare) possible-plans ] remaining-plans
      let remaining-plans-update filter [x -> member? choice-jurisdiction item 1 x] remaining-plans


      set manager-decision list choice-jurisdiction map [x -> item 0 x] remaining-plans-update

      if not projection? [
        print "______________________"
        print word "I am agent " name
        print word "the input plans were" inputs
        print word "the remaining plans are  "  remaining-plans
        print word "my preferences are " preferences
        print (word "my preferred plan is then " preferred-plan " containing the decisions " content-preferred-plan)
        print (word "given that my jurisdiction is " item 0 jurisdiction " my choice associated with my jurisdiction is "  choice-jurisdiction)
        print (word "the remaining plans after my decisions are " remaining-plans-update)
        print (word "my final choice is " manager-decision)
      ]

    ]

    ; if plan already chosen based on suggestions by the subordinates, then this plan is the final decision
    [
      set manager-decision remaining-plans

      if not projection? [
        print "______________________"
        print word "I am agent " name
        print word "the input plans were" inputs
        print word "the remining plans are  "  remaining-plans
        print (word "my final chioce is " manager-decision)
      ]
    ]

  ]

  [ ; if the decision rule managers = pure preferences, or managemement by exceptions
    ; shorten the inputs to the essential number
    set inputs remove-duplicates inputs

    print (word "I am agent " [name] of self " checking the inputs from my subordinates: " inputs)

    ; if the all subordinates agree on the suggested option, there is only one option
    ifelse (length inputs = 1) [ set manager-decision item 0 inputs]

    [; if subordinates disagree, what to do next depends on the decision rules of the managers

      ifelse  decision-rule-managers = "pure-preferences"
      [ set manager-decision choose-among-inputs-based-on-preferences inputs]

      [ ;MBE = management by exceptions, ignore the suggestions, and choose the more preferred option
        ifelse decision-rule-managers = "management-by-exceptions"
        [ set manager-decision item 0 preferences ]
        [print "you forgot to add the decision rules of the manager."]
      ]
    ]
  ]

  report manager-decision

end

to-report common-elements-lists [lists]

  if empty? lists [
    report []  ;; no lists → no common elements
  ]

  ;; start with the first list, then reduce through all others
  let result first lists

  foreach but-first lists [
    l -> set result list-intersection result l
  ]

  report result


end

to-report list-intersection [list1 list2]
  report remove-duplicates filter [x -> member? x list2] list1
end

to-report choose-among-inputs-based-on-preferences [inputs]

  let chosen-option "to be defined"

  ; make a list containing the ranking in the preferences of the specific jurisdiction list
  let positions map [ x -> (list (position x preferences) x) ] inputs
  ; pick the jurisdiction that has the highest ranking
  set chosen-option item 1 first sort-by [ [a b] -> (first a) < (first b) ] positions

  report chosen-option

end

to display-strategic-impact

  ifelse success-strategic? = "neutral"
  [
    ask bureaucrats with [ item 0 position-ag = 0] [
      let a sincere-decision-made-and-implications
      let b decision-made

       print (word "The outcome of the strategic decision making was neutral, meaning that the sincere outcome '" a "' is the same as the strategic one: '" b "'")

      ask label-agents with [associated-agent-id = [who] of myself] [
        set label (word "Neutral outcome " a " = " b )
      ]
    ]
  ]
  [ ifelse success-strategic? = true
    [
      ask structural-links [

        if (shared-decision !=  sincere-decision-shared-and-implications) and (sincere-decision-shared-and-implications != 0) [

          let label-owner-link-id name-link
          let a sincere-decision-shared-and-implications
          let b shared-decision

          ask one-of label-agents with [associated-link-id  = label-owner-link-id] [ set label (word a " -> " b) ]

        ]

      ]

      ask bureaucrats with [ item 0 position-ag = 0]
      [
        let a sincere-decision-made-and-implications
        let b decision-made

        print word "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~> the outcome based on the sicere decision would have been "  sincere-decision-made-and-implications

        print word "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~> the actual autcome was "  decision-made
        if a = 0 [
          print word "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~> something is wrong here for the sincere decision by the agent " name

        ]
        ask label-agents with [associated-agent-id = [who] of myself] [
          set label (word "Final decision: " a " -> " b)
        ]

      ]
    ]
    [
      ask bureaucrats with [ item 0 position-ag = 0] [
        let a sincere-decision-made-and-implications
        let b decision-made

        print (word "The outcome of the strategic decision making was negative, meaning that the sincere outcome '" a "' is preferred compared to the strategic one: '" b "'")
      ]
    ]


  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
17
43
818
481
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-30
30
-16
16
0
0
1
ticks
30.0

TEXTBOX
24
13
713
37
Agenda Control, Organizational Structure, and Bureaucratic Politics: replication via ABM of Hammond  (1986)
13
0.0
1

CHOOSER
17
499
266
544
Replicate-Hammond-experiment
Replicate-Hammond-experiment
"no" "P1-A" "P1-B" "P1-C" "P2-A" "P2-A-test" "P2-B"
1

BUTTON
280
499
560
545
NIL
Load-Hammond-experiments
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
574
499
819
545
NIL
go-hammond-experiments
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
