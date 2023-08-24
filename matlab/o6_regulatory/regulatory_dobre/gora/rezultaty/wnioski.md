Regulatory są w wersjach szybkie przesunięcie wózka do celu z dużym wychyleniem wahadła
i wolne przesunięcie wózka z małym wychyleniem wahadła
- przy tym drugim można postawić cos na wahadle i próbować przesunąć wózke np. szklanke

s1...s5 - modyfikacje zwykłego LQR

# s1 LQR - vid_0 i vid_1:
	- przy stałym zakłóceniu pozycja wózka jest nie taka jak zadana 

# s2 LQI - vid_2 i vid_3:
	- odrzucanie stałych zakłóceń
	- ale widać jakieś wychylenie wahadła w zadanej pozycji wózka (?)

# s3 LQR stan rozszerzony o u - vid_4 o vid_5
	- system rozszerzony poprawnie bo:
		R=0(0.001) i Q(5)=1 regulator jest równoważny do 
		LQR z systemu nie rozszerzonego 
		tj. przebiegi z vid_0 i vid_4 są takie same (bardzo zbliżone)
		
		wyjaśnienia:
		wyjasnienia_system_rozszerzony_o_u.txt
		
	- na przebiegach vid_4(R=000.1) i vid_5(R=1) widać, że większa kara na 
	  pochodną syg. sterującego powoduje rozciągnięcie sygnału sterującego
	  - czyli się zgadza to co miało być
	  
	- na animacja vid_4 i vid_5 widać różnicę, że na vid_4 mocniej szarpię wózek
	  na vid_5 ruch wózka jest dużo łagodniejszy
	  na przebiegach widać że vid_5 ma mniejsze wartości przyśpieszenia wózka niż na vid_4
	 
# s4 LQR z rozszerzoną funkcją celu żeby dało się wprowadzić kary za przyśpieszenie wózka i wahadła
	- działa ale wyniki gorsze niż w s3, w s3 ograniczając pochodną u ograniczałem przyśpieszenia i mogłem wpływać
	  na ->jakość<- sygnału sterującego - tutaj nie mam tej możliwości
	  
# s5 = s4+s3 - tj. rozszerzona funkcja celu LQR i dodany stan u

# s6 - stan rozszerzony o u i Du, nowe sterowanie to DDu, stan rozszerzony o drugą pochodną xw i theta
# po to aby w LQR mieć możliwość ogarniczenia trzeciej pochodnej xw i theta
# żeby nie szarpało

TERAZ PRZENIEŚĆ latexa DO OVERLEAFA





