unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, TabNotBk, StdCtrls, Buttons;

type
  TMainForm = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    Memo1: TMemo;
    Label3: TLabel;
    Memo2: TMemo;
    OpenDialog2: TOpenDialog;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label7: TLabel;
    ComboBox3: TComboBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    Memo3: TMemo;
    Button7: TButton;
    Button8: TButton;
    SaveDialog1: TSaveDialog;
    Button9: TButton;
    Button10: TButton;
    Label8: TLabel;
    Label9: TLabel;
    Button11: TButton;
    Edit2: TEdit;
    Label10: TLabel;
    BitBtn1: TBitBtn;
    SaveDialog2: TSaveDialog;
    OpenDialog3: TOpenDialog;
    Memo4: TMemo;
    Button14: TButton;
    Button12: TButton;
    Button13: TButton;
    Label11: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ComboBox4: TComboBox;
    Label12: TLabel;
    Label13: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Memo4Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit3Change(Sender: TObject);
    procedure Edit6Exit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ischar(c: char): boolean; forward;
function isstopword(w: string): boolean; forward;
procedure find_segment_pairs; forward;
procedure create_hash_table_with_lemmas; forward;
function get_lemma(w: string): string; forward;
procedure ExportToTxt(nro_rel: integer); forward;

const TAM=10000; //número máximo de segmentos por texto

type node=record
          word: string;
          lemma: string;
          next: pointer;
          end;

var
  MainForm: TMainForm;
  path: string;
  threshold: real; //word overlap threshold to determine whether segments are related
  wrap, change, texto1_carregado, texto2_carregado: boolean;
  texto1, texto2, stoplist: array[1..TAM] of string;
  top_texto1, top_texto2, top_stoplist: integer;
  hashtable: array[1..TAM] of pointer;

implementation

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
begin
        if (OpenDialog1.Execute) then
                Edit1.Text:=OpenDialog1.FileName;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var comando: string;
begin
        if (Edit1.Text<>'') then
                begin
                comando:=path+'\SENTER_Por.exe "'+Edit1.Text+'"';
                WinExec(PChar(comando),SW_HIDE);
                ShowMessage('Done!');
                end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var fin: TextFile;
    c: char;
    st: string;
begin
        GetDir(0,path);
        ComboBox1.Text:='';
        ComboBox3.Text:='';
        ComboBox4.ItemIndex:=0;
        Edit3.Text:='';
        wrap:=False;
        change:=False;
        texto1_carregado:=False;
        texto2_carregado:=False;

        //loading word overlap threshold
        threshold:=StrToFloat(Edit6.Text);

        //loading CST relations
        AssignFile(fin,path+'\relations.txt');
        Reset(fin);
        while (not(EOF(fin))) do
                begin
                read(fin,c);
                while ((not(EOF(fin))) and ((c=' ') or (c=#10) or (c=#13) or (c=#9))) do
                        read(fin,c);
                st:='';
                while ((not(EOF(fin))) and (c<>#10) and (c<>#13)) do
                        begin
                        st:=st+c;
                        read(fin,c);
                        end;
                if (st<>'') then
                        ComboBox3.Items.Add(st);
                end;
        CloseFile(fin);
        ComboBox3.ItemIndex:=0;

        //loading stoplist
        AssignFile(fin,path+'\stoplist.txt');
        Reset(fin);
        top_stoplist:=1;
        while (not(EOF(fin))) do
                begin
                read(fin,c);
                while ((not(EOF(fin))) and ((c=' ') or (c=#10) or (c=#13) or (c=#9))) do
                        read(fin,c);
                st:='';
                while ((not(EOF(fin))) and (c<>#10) and (c<>#13)) do
                        begin
                        st:=st+c;
                        read(fin,c);
                        end;
                if (st<>'') then
                        begin
                        stoplist[top_stoplist]:=st;
                        top_stoplist:=top_stoplist+1;
                        end;
                end;
        CloseFile(fin);

        //loading lemmas
        create_hash_table_with_lemmas;

end;

procedure TMainForm.Button3Click(Sender: TObject);
var fin: TextFile;
    c: char;
    st: string;
begin
        if (OpenDialog2.Execute) then
                begin
                Edit4.Text:=OpenDialog2.FileName;
                top_texto1:=1;
                Memo1.Lines.Clear;
                AssignFile(fin,OpenDialog2.FileName);
                Reset(fin);
                while (not(EOF(fin))) do
                        begin
                        read(fin,c);
                        while ((not(EOF(fin))) and ((c=' ') or (c=#10) or (c=#13) or (c=#9))) do
                                read(fin,c);
                        if (not(EOF(fin))) then
                                begin
                                st:='';
                                while ((not(EOF(fin))) and (c<>#10) and (c<>#13)) do
                                        begin
                                        st:=st+c;
                                        read(fin,c);
                                        end;
                                Memo1.Lines.Append('<'+IntToStr(top_texto1)+'> '+st+#10+#13+#10+#13);
                                texto1[top_texto1]:=st;
                                top_texto1:=top_texto1+1;
                                end;
                        end;
                CloseFile(fin);
                texto1_carregado:=True;
                if ((texto1_carregado=True) and (texto2_carregado=True)) then
                        find_segment_pairs;
                end;
end;

procedure TMainForm.Button4Click(Sender: TObject);
var fin: TextFile;
    c: char;
    st: string;
begin
        if (OpenDialog2.Execute) then
                begin
                Edit5.Text:=OpenDialog2.FileName;
                top_texto2:=1;
                Memo2.Lines.Clear;
                AssignFile(fin,OpenDialog2.FileName);
                Reset(fin);
                while (not(EOF(fin))) do
                        begin
                        read(fin,c);
                        while ((not(EOF(fin))) and ((c=' ') or (c=#10) or (c=#13) or (c=#9))) do
                                read(fin,c);
                        if (not(EOF(fin))) then
                                begin
                                st:='';
                                while ((not(EOF(fin))) and (c<>#10) and (c<>#13)) do
                                        begin
                                        st:=st+c;
                                        read(fin,c);
                                        end;
                                Memo2.Lines.Append('<'+IntToStr(top_texto2)+'> '+st+#10+#13+#10+#13);
                                texto2[top_texto2]:=st;
                                top_texto2:=top_texto2+1;
                                end;
                        end;
                CloseFile(fin);
                texto2_carregado:=True;
                if ((texto1_carregado=True) and (texto2_carregado=True)) then
                        find_segment_pairs;
                end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
        Memo1.Clear;
        Label5.Caption:='Segment pairs';
        ComboBox1.Clear;
        Edit4.Text:='';
        texto1_carregado:=False;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
        Memo2.Clear;
        Label5.Caption:='Segment pairs';
        ComboBox1.Clear;
        Edit5.Text:='';
        texto2_carregado:=False;
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
        if (OpenDialog1.Execute) then
                Memo3.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TMainForm.Button8Click(Sender: TObject);
begin
        if (SaveDialog1.Execute) then
                Memo3.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
        Memo3.Clear;
end;

procedure TMainForm.Button10Click(Sender: TObject);
begin
        if (wrap=False) then
                begin
                wrap:=True;
                Memo3.ScrollBars:=ssBoth;
                Button10.Caption:='Wrap lines';
                Button10.Repaint;
                end
        else begin
             wrap:=False;
             Memo3.ScrollBars:=ssVertical;
             Button10.Caption:='Do not wrap lines';
             Button10.Repaint;
             end;
end;

procedure TMainForm.Button11Click(Sender: TObject);
begin
        if (Edit2.Text<>'') then
                begin
                ComboBox3.Items.Add(Edit2.Text);
                Edit2.Text:='';
                end;
end;

procedure TMainForm.Button13Click(Sender: TObject);
begin
        Memo4.Clear;
        change:=True;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
var st1, st2, seg1, seg2: string;
    i: integer;
begin
        if ((ComboBox1.Text<>'') and (ComboBox3.Text<>'') and (ComboBox4.Text<>'') and (Edit3.Text<>'')) then
                begin
                //recuperando o nome dos textos (sem o caminho)
                st1:='';
                for i:=1 to length(Edit4.Text) do
                        if (Edit4.Text[i]='\') then
                                st1:=''
                        else st1:=st1+Edit4.Text[i];
                st2:='';
                for i:=1 to length(Edit5.Text) do
                        if (Edit5.Text[i]='\') then
                                st2:=''
                        else st2:=st2+Edit5.Text[i];
                //recuperando segmentos
                seg1:='';
                i:=1;
                while ((ComboBox1.Text[i]<>' ') and (ComboBox1.Text[i]<>'-')) do
                        begin
                        seg1:=seg1+ComboBox1.Text[i];
                        i:=i+1;
                        end;
                seg2:='';
                while ((ComboBox1.Text[i]=' ') or (ComboBox1.Text[i]='-')) do
                        i:=i+1;
                while (i<=length(ComboBox1.Text)) do
                        begin
                        seg2:=seg2+ComboBox1.Text[i];
                        i:=i+1;
                        end;
                //incluindo na base de relações
                if ((ComboBox4.ItemIndex=0) or (ComboBox4.ItemIndex=1)) then
                        Memo4.Lines.Append('<R SDID="'+st1+'" SSENT="'+seg1+'" TDID="'+st2+'" TSENT="'+seg2+'">'+#13+#10+'<RELATION TYPE="'+ComboBox3.Text+'" JUDGE="'+Edit3.Text+'"/>'+#13+#10+'</R>')
                else Memo4.Lines.Append('<R SDID="'+st2+'" SSENT="'+seg2+'" TDID="'+st1+'" TSENT="'+seg1+'">'+#13+#10+'<RELATION TYPE="'+ComboBox3.Text+'" JUDGE="'+Edit3.Text+'"/>'+#13+#10+'</R>');

                change:=True;
                end
        else ShowMessage('Error: some information is missing!');

end;

procedure TMainForm.Button12Click(Sender: TObject);
begin
        if (SaveDialog2.Execute) then
                begin
                Memo4.Lines.SaveToFile(SaveDialog2.FileName);
                change:=False;
                end;
end;

procedure TMainForm.Button14Click(Sender: TObject);
begin
        if (OpenDialog3.Execute) then
                Memo4.Lines.LoadFromFile(OpenDialog3.FileName);
end;

procedure TMainForm.Memo4Change(Sender: TObject);
begin
        change:=True;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var i: integer;
    p: ^node;
begin
        if (change=True) then
                if MessageBox(Handle,'It looks that you changed your CST analysis and did not save it. Do you want to save the changes?','Attention',MB_YESNO)=IDYES then
                        if (SaveDialog2.Execute) then
                                Memo4.Lines.SaveToFile(SaveDialog2.FileName);

        //freeing space used by hash table of lemmas
        for i:=1 to TAM do
                while (hashtable[i]<>nil) do
                        begin
                        p:=hashtable[i];
                        hashtable[i]:=p^.next;
                        dispose(p);
                        end;
end;

//This fucntion verifies whether the caracter is a valid character
function ischar(c: char): boolean;
begin
        if (((c>='a') and (c<='z')) or
           ((c>='A') and (c<='Z')) or
           (c='á') or (c='é') or (c='í') or (c='ó') or (c='ú') or
           (c='â') or (c='ê') or (c='î') or (c='ô') or (c='û') or
           (c='ã') or (c='õ') or
           (c='à') or (c='è') or (c='ì') or (c='ò') or (c='ù') or
           (c='ä') or (c='ë') or (c='ï') or (c='ö') or (c='ü') or
           (c='ç') or (c='ý') or (c='ÿ') or
           (c='Á') or (c='É') or (c='Í') or (c='Ó') or (c='Ú') or
           (c='Â') or (c='Ê') or (c='Î') or (c='Ô') or (c='Û') or
           (c='Ã') or (c='Õ') or
           (c='À') or (c='È') or (c='Ì') or (c='Ò') or (c='Ù') or
           (c='Ä') or (c='Ë') or (c='Ï') or (c='Ö') or (c='Ü') or
           (c='Ç') or (c='Ý') or (c='Ÿ') or
           ((c>='0') and (c<='9')) or
           (c='-') or (c='_'))
          then ischar:=True
          else ischar:=False;
end;


//This fucntion verifies whether the word is a stopword
function isstopword(w: string): boolean;
var i: integer;
    test: boolean;
begin
        test:=False;
        i:=1;
        while ((i<=top_stoplist-1) and (test=False)) do
                if (stoplist[i]=w) then
                        test:=True
                else i:=i+1;

        isstopword:=test;
end;


//this procedure reads the file lemmas.txt and creates a hash table with the words and their lemmas
procedure create_hash_table_with_lemmas;
var p: ^node;
    i, hash_value: integer;
    fin: TextFile;
    c: char;
    word, lemma: string;
begin
        //starting table
        for i:=1 to TAM do
                hashtable[i]:=nil;

        //processing file with lemmas
        AssignFile(fin,path+'\lemmas.txt');
        Reset(fin);

        read(fin,c);
        while ((not(EOF(fin))) and ((c=' ') or (c=#10) or (c=#13) or (c=#9))) do
                read(fin,c);

        while (not(EOF(fin))) do
                begin

                //reading one word and the corresponding lemma
                word:='';
                while ((not(EOF(fin))) and (c<>',')) do
                        begin
                        word:=word+c;
                        read(fin,c);
                        end;
                read(fin,c);
                lemma:='';
                while ((not(EOF(fin))) and (ischar(c))) do
                        begin
                        lemma:=lemma+c;
                        read(fin,c);
                        end;

                //storing word and lemma
                if ((word<>'') and (lemma<>'')) then
                        begin
                        new(p);
                        p^.word:=word;
                        p^.lemma:=lemma;
                        hash_value:=0;
                        for i:=1 to length(word) do
                                hash_value:=hash_value+ord(word[i]);
                        hash_value:=hash_value mod TAM;
                        p^.next:=hashtable[hash_value];
                        hashtable[hash_value]:=p;
                        end;

                while ((not(EOF(fin))) and (not(ischar(c)))) do
                        read(fin,c);
                end;

        CloseFile(fin);
end;


//this function returns the lemma of a word
function get_lemma(w: string): string;
var i, hash_value: integer;
    test: boolean;
    p: ^node;
    lemma: string;
begin
        //calculating the hash value
        hash_value:=0;
        for i:=1 to length(w) do
                hash_value:=hash_value+ord(w[i]);
        hash_value:=hash_value mod TAM;

        //looking in the hash table
        test:=False;
        p:=hashtable[hash_value];
        while ((p<>nil) and (test=False)) do
                if (p^.word=w) then
                        begin
                        lemma:=p^.lemma;
                        test:=True;
                        end
                else p:=p^.next;

        //returning lemma or the own word if lemma is not found
        if (test=True)
                then get_lemma:=lemma
                else get_lemma:=w;
end;


//this procedure applies word overlap measure between the sentences of two texts to identify those which are related
procedure find_segment_pairs;
var words_text1, words_text2: array [1..TAM] of string;
    top_w1, top_w2, i, j, k, x, y, counter: integer;
    st, segment: string;
    found: boolean;
    wo: real;
begin
        MainForm.ComboBox1.Clear;

        counter:=0;

        for i:=1 to top_texto1-1 do
                begin
                //getting the words from the ith sentence of text 1
                st:='';
                top_w1:=1;
                segment:=texto1[i];
                for k:=1 to length(segment) do
                        begin
                        if (ischar(segment[k])) then
                                st:=st+segment[k]
                        else if ((not(ischar(segment[k]))) or (k=length(segment))) then
                                if (st<>'') then
                                        begin
                                        st:=AnsiLowerCase(st);
                                        if (not(isstopword(st))) then
                                                begin
                                                words_text1[top_w1]:=get_lemma(st);
                                                top_w1:=top_w1+1;
                                                end;
                                        st:='';
                                        end;
                        end;

                //getting the words from the jth sentence of text 2
                for j:=1 to top_texto2-1 do
                        begin
                        st:='';
                        top_w2:=1;
                        segment:=texto2[j];
                        for k:=1 to length(segment) do
                                begin
                                if (ischar(segment[k])) then
                                        st:=st+segment[k]
                                else if ((not(ischar(segment[k]))) or (k=length(segment))) then
                                        if (st<>'') then
                                                begin
                                                st:=AnsiLowerCase(st);
                                                if (not(isstopword(st))) then
                                                        begin
                                                        words_text2[top_w2]:=get_lemma(st);
                                                        top_w2:=top_w2+1;
                                                        end;
                                                st:='';
                                                end;
                                end;

                                //counting the number of common words among the ith and jth segments from text 1 and 2, respectively
                                wo:=0;
                                for x:=1 to top_w1-1 do
                                        begin
                                        y:=1;
                                        found:=False;
                                        while ((y<=top_w2-1) and (not(found))) do
                                                if (words_text1[x]=words_text2[y]) then
                                                        begin
                                                        wo:=wo+2;
                                                        words_text2[y]:='###';
                                                        found:=True;
                                                        end
                                                else y:=y+1;
                                        end;
                                wo:=wo/((top_w1-1)+(top_w2-1));

                               //including in the segment pairs list if their measure>=threshold
                               if (wo>=threshold) then
                                        begin
                                        MainForm.ComboBox1.Items.Add(IntToStr(i)+' - '+IntToStr(j){+'  ('+FloatToStr(round(wo*100)/100)+')'});
                                        counter:=counter+1;
                                        end;
                        end;
                end;

        MainForm.Label5.Caption:='Segment pairs '+'('+IntToStr(counter)+' out of '+IntToStr((top_texto1-1)*(top_texto2-1))+')';
        MainForm.ComboBox1.ItemIndex:=0;

        ExportToTxt(counter);
end;


procedure ExportToTxt(nro_rel: integer);
var arq: TextFile;
    i: integer;
begin
        AssignFile(arq,'analysis-CSTTool.txt');
        Rewrite(arq);

        //writing text 1 to the file
        write(arq,MainForm.Edit4.Text+#13+#10+#13+#10);
        for i:=1 to length(MainForm.Memo1.Text) do
                write(arq,MainForm.Memo1.Text[i]);

        //writing text 2 to the file
        write(arq,#13+#10+MainForm.Edit5.Text+#13+#10+#13+#10);
        for i:=1 to length(MainForm.Memo2.Text) do
                write(arq,MainForm.Memo2.Text[i]);

        //writing segment pairs to the file
        write(arq,#13+#10+MainForm.Label5.Caption+#13+#10+#13+#10);
        for i:=0 to nro_rel-1 do
                write(arq,MainForm.ComboBox1.Items[i]+#13+#10);

        CloseFile(arq);
end;


procedure TMainForm.Edit3Change(Sender: TObject);
begin
        if (Edit3.Text<>'') then
                Edit3.Color:=cl3Dlight
        else Edit3.Color:=clAqua;
end;


procedure TMainForm.Edit6Exit(Sender: TObject);
begin
        if (threshold<>StrToFloat(Edit6.Text)) then
                begin
                threshold:=StrToFloat(Edit6.Text);
                if ((texto1_carregado=True) and (texto2_carregado=True)) then
                        find_segment_pairs;
                end;
end;

end.
