
'----------------------------------------------------------------------------------------------
'
' KLife.bas
'
' Name:           Kaleido Life
' Description:    Cellular Automata cycling into kaleidoscope-like patterns.
' Copyright:      Martin Latter, June 2013.
' Version:        0.04
' License:        MIT
' URL:            https://github.com/Tinram/KLife.git
'
'----------------------------------------------------------------------------------------------


CONST AS UINTEGER cSW = 600, cSH = 600 ' screen dimensions


TYPE tCell

	PRIVATE:
		lastState AS UINTEGER

	PUBLIC:
		x AS UINTEGER
		y AS UINTEGER
		state AS UINTEGER
		nextState AS UINTEGER
		color AS UINTEGER

		DECLARE CONSTRUCTOR()
		DECLARE SUB calcNextState()

END TYPE


CONSTRUCTOR tCell()

	this.color = RGB(0, 0, 0)
	this.state = 0
	this.lastState = 0
	this.nextState = 0

END CONSTRUCTOR


RANDOMIZE (TIMER * 7000), 3

SCREENRES cSW, cSH, 32

DIM AS ULONG PTR pSPTR = SCREENPTR ' fbc x64, use UINTEGER for x32
DIM AS UINTEGER iXP, iYP
DIM AS INTEGER mX, mY, mB
DIM SHARED AS UINTEGER iSX, iSY
DIM SHARED AS INTEGER nextStateHigh = 255, nextStateLow = 0
DIM AS STRING sXClicked = CHR(255) + "k", sFilename
DIM AS DOUBLE fTimer, fLog

SCREENINFO iSX, iSY


DIM SHARED AS tCell aCells(0 TO iSX - 1, 0 TO iSY - 1)
	' shared:
	'	1. needed for use in tCell.calcNextState()
	' 	2. puts aCells in heap; not enough room in stack for over 200x200


SUB tCell.calcNextState()

	DIM AS INTEGER above = this.y - 1
	DIM AS INTEGER below = this.y + 1
	DIM AS INTEGER left = this.x - 1
	DIM AS INTEGER right = this.x + 1

	DIM AS SINGLE total = 0
	DIM AS INTEGER average = 0

	IF above < 0 THEN above = this.y - 1
	IF below = this.y THEN below = 0
	IF left < 0 THEN left = this.x - 1
	IF right = this.x THEN right = 0

	IF above > 0 AND above < (iSY - 1) THEN
		IF below > 0 AND below < (iSY - 1) THEN
			IF left > 0 AND left < (iSX - 1) THEN
				IF right > 0 AND right < (iSX - 1) THEN
					total += aCells(left, above).state
					total += aCells(left, this.y).state
					total += aCells(left, below).state
					total += aCells(this.x, below).state
					total += aCells(right, below).state
					total += aCells(right, this.y).state
					total += aCells(right, above).state
					total += aCells(this.x, above).state
				END IF
			END IF
		END IF
	END IF

	average = CINT(total / 8)

	IF average >= 512 THEN
		this.nextState = 0
	ELSEIF average <= 0 THEN
		this.nextState = 255
	ELSE
		this.nextState = this.state + average
		IF this.lastState > 0 THEN this.nextState -= this.lastState

		IF this.nextState > 255 THEN
			this.nextState = nextStateHigh
		ELSEIF this.nextState < 0 THEN
			this.nextState = nextStateLow
		END IF
	END IF

	this.lastState = this.state
	this.color = RGB(this.state, this.state, this.state)

END SUB


SUB winTitle()
	WindowTitle " KLife   ~   high: " & nextStateHigh & "  low: " & nextStateLow & " | F1 - F4 | R : reset | S: screenshot | ESC: exit"
END SUB


SUB resetScreen(BYVAL iSeed AS UINTEGER = 64)

	DIM AS UINTEGER iXP, iYP
	DIM AS DOUBLE fSeed = 1 / iSeed

	FOR iXP = 0 TO cSW - 1
		FOR iYP = 0 TO cSH - 1
			aCells(iXP, iYP).x = iXP
			aCells(iXP, iYP).y = iYP
			aCells(iXP, iYP).nextState = ((iXP / cSW) + (iYP / cSH)) * fSeed
			aCells(iXP, iYP).state = aCells(iXP, iYP).nextState
		NEXT iYP
	NEXT iXP

END SUB


' ############


WinTitle()

resetScreen()


DO

	FOR iXP = 0 TO iSX - 1
		FOR iYP = 0 TO iSY - 1
			aCells(iXP, iYP).calcNextState()
		NEXT iYP
	NEXT iXP

	SCREENLOCK
		FOR iXP = 0 TO iSX - 1
			FOR iYP = 0 TO iSY - 1
				pSPTR[ ( iYP * iSX ) + iXP ] = aCells(iXP, iYP).color
				aCells(iXP, iYP).state = aCells(iXP, iYP).nextState
			NEXT iYP
		NEXT iXP
	SCREENUNLOCK

	IF MULTIKEY(&h1F) THEN
		sFilename = "KLife_" & CINT(TIMER) & ".bmp"
		BSAVE sFilename, 0
	END IF

	IF MULTIKEY(&h13) THEN
		resetScreen(CINT(RND * 100))
	END IF

	IF MULTIKEY(&h3C) THEN
		nextStateHigh += 2
		IF nextStateHigh > 260 THEN nextStateHigh = 260
		winTitle()
	END IF

	IF MULTIKEY(&h3B) THEN
		nextStateHigh -= 2
		IF nextStateHigh < -2 THEN nextStateHigh = -2
		winTitle()
	END IF

	IF MULTIKEY(&h3E) THEN
		nextStateLow += 2
		IF nextStateLow > 260 THEN nextStateLow = 260
		winTitle()
	END IF

	IF MULTIKEY(&h3D) THEN
		nextStateLow -= 2
		IF nextStateLow < -2 THEN nextStateLow = -2
		winTitle()
	END IF

	GETMOUSE mX, mY,, mB

	IF mB > 0 THEN

		SELECT CASE mB

			CASE 1 ' black

				DIM AS INTEGER xx, yy

				FOR y AS INTEGER = -25 TO 25 ' circle generator, credit: David Watson
					FOR x AS INTEGER = -25 TO 25
						xx = mX + x
						yy = mY + y
						IF xx >= 0 AND xx <= cSW AND yy >= 0 AND yy <= cSH THEN
							IF SQR(ABS(x) * ABS(x) + ABS(y) * ABS(y)) < 26 THEN
								aCells(xx, yy).state = 1 + RND * 2
							END IF
						END IF
					NEXT x
				NEXT y

			CASE 2 ' white

				DIM AS UINTEGER xx, yy

				FOR y AS INTEGER = -25 TO 25
					FOR x AS INTEGER = -25 TO 25
						xx = mX + x
						yy = mY + y
						IF xx >= 0 AND xx <= cSW AND yy >= 0 AND yy <= cSH THEN
							IF SQR(ABS(x) * ABS(x) + ABS(y) * ABS(y)) < 26 THEN
								aCells(xx, yy).state = 255 - RND * 2
							END IF
						END IF
					NEXT x
				NEXT y

		END SELECT

	END IF

LOOP UNTIL MULTIKEY(&h01) OR INKEY = sXClicked


ERASE aCells
