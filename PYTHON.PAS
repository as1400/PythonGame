{$C-}
program PythonGame;

const
  cdelay = 100;    { for delay: mSec) }
  max_x = 89;      { display width-1  }
  max_y = 29;      { display high-1   }
  max_len = 1023;  { max length python }
  wf = 5;          { weight frog }
  pylen = 5;       { initial length python }
  CTry = 5;      { try's }

{ controls keys }
  _ESC = #27;
  _RIGHT = #4;
  _LEFT = #19;
  _UP = #5;
  _DOWN = #24;

{ ANSI screen attributes }
  _CLS = #27'[2J';
  _ATR = #27'[0m';
  _COFF = #27'[?25l';
  _CON = #27'[?25h';
  _BLACK = #27'[30m';
  _RED = #27'[31m';
  _GREEN = #27'[32m';
  _YELLOW = #27'[33m';
  _BLUE = #27'[34m';
  _MAGENTA = #27'[35m';
  _CYAN = #27'[36m';
  _WHITE = #27'[37m';
  _CR = #13;

type
    tpython = record
           x: array[0..max_len] of byte;
           y: array[0..max_len] of byte;
           head: integer;
           tail: integer;
           lfact: integer;
           len: integer;
           dx: byte;
           dy: byte;
     end;

    tfrog = record
          x: byte;
          y: byte;
     end;

var
  py: tpython;
  frog: tfrog;
  c: char;
  game: boolean;
  bx,by: byte;
  try: byte;

procedure DrawBorder;
var
   l: byte;
begin
   write(_RED);
   for l:=1 to max_x do
     begin
        gotoxy(l,1); write('X');
        gotoxy(l,max_y); write('X');
     end;
   for l:=2 to max_y-1 do
     begin
        gotoxy(1,l); write('X');
        gotoxy(max_x,l); write('X');
     end;
   write(_GREEN);
end;

function CheckCollision(xx,yy:byte):boolean;
var
   ptr: integer;
begin
     CheckCollision:=false;
     if (xx=1) or (yy=1) or (xx>=max_x) or (yy>=max_y) then
        CheckCollision:=true;
     ptr:=py.tail;
     while ptr<>py.head do
     begin
           if (py.x[ptr]=xx) and (py.y[ptr]=yy) then
              CheckCollision:=true;
           if ptr=max_len then ptr:=0
                      else ptr:=ptr+1;
     end;
end;

procedure NewFrog;
begin
   repeat
      frog.x:=random(max_x-4)+3; frog.y:=random(max_y-4)+3;
   until CheckCollision(frog.x,frog.y)=false;
   gotoxy(frog.x,frog.y);
   write(_YELLOW,'*',_GREEN);
end;

procedure Score;
begin
   gotoxy((max_x div 2)-12,0);
   write(_CYAN,' Score: ',py.len,'  Python''s: ',try,' ',_GREEN);
end;

begin
try:=CTry; py.len:=pylen;
repeat
   write(_CLS,_ATR,_COFF);
   DrawBorder;

   py.dx:=1; py.dy:=0;
   py.lfact:=0;
   py.head:=0; py.tail:=0;
   py.x[py.head]:=10; py.y[py.head]:=10;
   Score;

   NewFrog;

   game:=true;
   while game do
   begin
      bx:=py.x[py.head]; by:=py.y[py.head];
      if py.head=max_len then py.head:=0
               else py.head:=py.head+1;
      py.x[py.head]:=bx+py.dx; py.y[py.head]:=by+py.dy;
      gotoxy(py.x[py.head],py.y[py.head]); write('O');

      if CheckCollision(py.x[py.head],py.y[py.head]) then game:=false;

      if (py.x[py.head]=frog.x) and (py.y[py.head]=frog.y) then
         begin
              py.len:=py.len+wf;
              Score;
              NewFrog;
         end;

      if py.lfact=py.len then
         begin
           gotoxy(py.x[py.tail],py.y[py.tail]); write(' ');
           if py.tail=max_len then py.tail:=0
                    else py.tail:=py.tail+1;
         end
      else py.lfact:=py.lfact+1;

     delay(cdelay);

     if KeyPressed then
        read(Kbd,c);
           case c of
                _RIGHT: if py.dx=0 then
                          begin
                            py.dx:=1;
                            py.dy:=0;
                          end;
                _LEFT:  if py.dx=0 then
                          begin
                            py.dx:=-1;
                            py.dy:=0;
                          end;
                _UP:    if py.dy=0 then
                          begin
                            py.dy:=-1;
                            py.dx:=0;
                          end;
                _DOWN:  if py.dy=0 then
                          begin
                            py.dy:=1;
                            py.dx:=0;
                          end;
                _ESC: game:=false;
           end;
   end;
   try:=try-1;
   Score;
   c:=#0;
   if try>0 then begin
      gotoxy((max_x div 2)-6,(max_y div 2));
      write(_WHITE,'Repeat (y/n)');
      repeat
         read(Kbd, c);
      until (c='y') or (c='n');
   end;
until (try=0) or (c='n');

gotoxy((max_x div 2)-12,(max_y div 2));
writeln(_YELLOW,'GAME OVER! (press Enter)');
repeat
   read(Kbd, c);
until c=_CR;

writeln(_CLS,_ATR,_CON,_CR);
end.
