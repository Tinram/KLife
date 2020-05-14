
# makefile for KLife

CC = fbc
CFLAGS = -w all -gen gcc -O max -Wl -s
NAME = KLife
INPUTLIST = KLife.bas

klife:
	$(CC) $(CFLAGS) $(INPUTLIST) -x $(NAME)