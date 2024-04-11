# frozen_string_literal: true

OUTSIDE_CONTRACT = [
  %w[0382170C 2472000831],
  %w[0690652J 2472340732],
  %w[0690652J 2472340733],
  %w[0690652J 2412010122],
  %w[0690652J 2412344721],
  %w[0690652J 2412344722],
  %w[0690652J 2412521921],
  %w[0690652J 2412521922],
  %w[0690652J 2412543422],
  %w[0691875N 2473360333],
  %w[0691875N 2473360531],
  %w[0691875N 2473360632],
  %w[0691875N 2413361521],
  %w[0691875N 2413361522],
  %w[0442083A 2473121131],
  %w[0442083A 2473121332],
  %w[0442083A 2473121333],
  %w[0442227G 2403320511],
  %w[0910838S 2473000433],
  %w[0910838S 2473121432]
].freeze


BAD_RIB_IDS = %w[944 299343 457877 2353 3583 6437 7105 9108 10032 14813 18395 18375 18416 23773 23823 29225 29276 29338 30235 37696 34459 36810 41381 38410 38862 40168 39466 41746 42774 45861 43488 46245 368928 50181 48182 48742 50675 50728 50736 50784 50792 50802 51127 54008 57765 53681 54521 60707 61369 61789 61967 66787 63917 70103 69942 72435 74673 72839 74728 79763 80023 82702 83506 82640 83882 86334 85930 87605 87524 88778 87956 87984 88109 89262 97433 90633 90597 92206 97562 99642 101541 100526 106273 103552 105669 105800 106485 109401 110090 111350 114319 114498 114998 114833 115073 115091 114965 116992 116699 116639 117321 121431 127457 120068 120490 120705 121478 121496 122119 122937 122997 125048 124289 135106 128386 128438 131631 134706 135164 135367 136177 135072 139124 139169 139376 147620 139626 458552 141182 141259 144652 147548 149395 148514 152427 150198 150455 150625 151194 153038 152999 153160 155728 22875 155971 156160 156362 158240 156133 158249 159402 160980 163113 163523 163581 163895 164427 166193 193757 171146 169764 174402 174314 176117 174894 175009 177088 177670 177507 180966 181154 186459 180904 182491 182439 182725 182695 188225 192676 188351 189705 189955 190237 195564 192844 196451 196828 241703 198043 198244 199124 204874 203026 208884 210536 209358 209949 211134 210305 215241 210980 221104 215890 218351 219013 221606 221624 221716 221729 221637 221704 223978 224044 224033 224851 228056 231168 228928 228950 229619 230286 231245 231120 232422 231102 231263 231882 237562 238106 242813 235171 244822 249519 246465 249652 250221 250997 251903 252412 252725 254278 254237 254709 254839 260217 255176 256337 257838 257935 299647 259110 260840 263252 261660 262301 263469 263537 266045 267783 266556 268043 270991 267868 268225 258541 271440 300144 275176 272826 300012 273404 276063 277331 300177 278249 280245 280351 281126 300225 280715 281883 285170 283649 283745 285690 292328 290948 294821 292324 292422 292279 292772 292880 295226 296760 300842 297367 297413 297467 297536 301153 300900 301205 301336 301979 302312 302702 302531 304556 308164 306546 308270 313732 314427 318402 317858 322326 319496 319863 320113 323685 324644 327591 370074 325326 369958 327318 327986 459324 330132 330177 331535 331817 333131 331902 331936 335271 371057 333365 335009 335290 338635 336274 339485 342601 263185 100293 346616 344206 469864 346856 372142 347151 347589 347870 348020 348091 350592 348743 357039 351043 351242 353297 354266 372586 355514 358201 357488 357479 357503 359201 359755 360356 361406 361380 361420 363371 363322 363364 363303 363296 363817 363612 365177 373217 460663 367629 374831 367933 373634 373722 375010 373891 374038 375137 376420 375675 378059 376715 377141 378412 378459 378600 190136 379314 380307 380540 381253 381869 461713 461728 389199 386132 461815 387333 363809 389064 363288 363858 389168 363347 389829 363829 389959 389608 392055 393279 393701 393709 394031 394842 395270 394637 395646 395464 396252 395578 397178 396527 462598 397453 462734 397331 397472 398034 363331 363355 398589 462985 398366 469959 399467 400161 400245 400034 400050 400277 400315 400321 400324 400663 400868 400677 400556 400670 400544 400575 400878 400550 400562 404029 400865 401008 400969 402548 405618 404863 404876 404694 404852 404859 405213 406622 407325 408749 407263 407356 408259 409302 409432 409389 409401 411397 464214 464286 411382 411440 412089 412348 412090 412097 412056 412587 412444 412372 412462 412925 413062 412836 413387 464564 413855 414121 464566 415694 464763 464764 416455 418067 418748 419616 420191 422014 422055 422368 422924 423145 427317 466114 424451 425093 427412 427226 427241 427404 427903 427869 427965 429015 429541 429455 429573 429494 430224 430285 430456 470205 433844 431207 466814 432875 433082 433195 435334 435419 435568 435882 435788 436489 467566 467882 467536 439970 441241 467595 467689 440425 441025 441920 442163 442603 468166 443324 443198 443634 443680 443738 443845 470805 444079 444365 444653 449330 444695 444801 445082 445161 445175 468538 446461 447417 447884 70649 449312 449349 449553 449617 449743 449726 449772 449825 449834 449840 450564 450788 469021 451739 469034 452089 452079 449512 470692 453772 456656 454298 455575 456879 457724 457662 457797 470962 215998 473183 471751 472484 472458 473261 477454 473821 474185 474571 474792 476724 476895 477485 477411 478770 476995 477669 477917 478125 480507 479139 480878 483012 481634 483028 483310 483302 483774 484324 391362 484478 484473 485403 388263 486636 487314 485837 487940 488803 489107 489951 490034 490387 490551 490565 491210 491653 491441 491732 491663 491710 491919 491756 492052 493570 493772 493582 493923 493798 493827 495147 495160 495513 496357 495411 498188 121239 498249 498244 498496 498675 499074 499057 492287 500457 501024 501079 501295 501362 503630 502065 503556 503929 504132 505679 505759 502474 506236 509837 507769 509788 509827 509862 509889 510434 510566 510592 510584 513019 510614 511445 511471 511516 511876 513189 514159 513986 516667 514729 516658 517098 517154 518602 517260 518215 518294 519710 519899 521343 521719 521722 521967 522289 523153 523156 523691 523690 523681 524663 525996 526761 526617 527560 527792 528014 533526 528374 528436 528440 528453 528485 528772 528844 529278 531271 531684 533944 534705 535272 536190 536250 535846 536414 537026 537141 536977 536956 538518 537316 537366 540010 538459 538648 538664 538774 539834 539843 540020 541107 540466 540470 540461 540453 540497 540582 540684 541351 541367 542040 543224 542344 543085 543750 543212 544823 546375 544945 548463 546594 546596 547030 547002 548510 548769 548750 549059 549792 549678 549708 549688 550818 551026 552887 551010 551916 552550 552599 552860 553505 553732 554013 553521 554175 554531 554562 554406 556390 554113 555071 555223 555655 555997 557085 557518 558055 558661 558728 558899 561634 559046 559325 559403 559636 559999 560044 560612 561056 561077 561068 561523 562127 562233 562899 562960 562871 562432 563750 564268 564361 564402 565712 567698 566449 566736 568256 567974 568789 570571 570222 570235 570205 573632 572301 572651 572653 573017 573001 573250 387072 573941 574203 574326 573426 575290 574767 575683 576359 575677 575976 576002 576658 577156 577287 577387 577379 577860 577992 578405 578963 578985 579020 579225 582967 580720 582252 583861 583226 583392 583434 583634 583936 583917 583929 586090 213166 585837 585893 586402 586407 588572 587731 588687 588684 589571 118113 209455 210054 215377 219823 261700 355393 357701 358646 363263 363276 363308 363338 363603 413463 557502 558869].freeze

PRIVATE_HEALTH_ESTABLISHMENTS = %w[0541769E 0010212A 0930075B].freeze

def outside_contract?(pfmp)
  OUTSIDE_CONTRACT.any? { |uai, mef| pfmp.establishment.uai == uai && pfmp.mef.code == mef }
end

def needs_abrogated_da?(pfmp)
  pfmp.student.pfmps.joins(:mef).select(:"mefs.id").distinct.count > 1 &&
    pfmp.student.schoolings.joins(:classe).select(:"establishment_id").distinct.count > 1
end

def check_10_000_payment_requests
  ASP::PaymentRequest
    .in_state(:pending)
    .joins(pfmp: :establishment)
    .merge(Pfmp.in_state(:validated))
    .merge(Pfmp.perfect)
    .where.not("ribs.id": BAD_RIB_IDS)
    .where("students.ine_not_found": false)
    .where("schoolings.attributive_decision_version < 10") # one_character_attributive_decision_version?
    .where.not("ribs.name LIKE '%¨%' OR ribs.name LIKE '%;%'") # remove after fix
    .where.not("establishments.department_code": nil) # remove after adding a fallback on postal code
    .order("pfmps.end_date")
    .limit(10_000)
    .each_with_index
    .filter do |request, index|
    puts "dealing with #{request.id} [#{index}/10k]..."
    pfmp = request.pfmp

    if pfmp.valid? &&
        !outside_contract?(pfmp) &&
        !needs_abrogated_da?(pfmp)
      request.transition_to(:ready)
    else
      request.transition_to(:incomplete)
    end
  end
end

# The command which doesn't print the whole universe on your console
check_10_000_payment_requests; p "done"

##############################################
## Pour envoyer 7k PFMPS ready en paiement ###

ASP::PaymentRequest.joins(ASP::PaymentRequest.most_recent_transition_join).group(:to_state).count

# Check si y'a moins de 100k en cours cette semaine
ASP::PaymentRequest.in_state(%i[sent integrated rejected]).where("most_recent_asp_payment_request_transition.created_at >= ?", Date.today.beginning_of_week).count

# Select 7k and send them
prs = ASP::PaymentRequest.in_state(:ready).joins(:pfmp).order(:end_date).limit 7000
SendPaymentRequestsJob.perform_later(prs.to_a); p "Job started !"



#####################################################################
## Pour récupérer les status du serveur ASP (1x par jour le matin) ##

PollPaymentsServerJob.perform_later

