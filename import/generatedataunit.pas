{ Free DB Manager

  Copyright (C) 2005-2019 Lagunov Aleksey  alexs75 at yandex.ru

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit GenerateDataUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel, ExtCtrls,
  StdCtrls, Spin, ActnList, Menus, DBCtrls, ComCtrls, DB, rxmemds, rxdbgrid,
  rxtooledit, SQLEngineAbstractUnit, fbmsqlscript;

type

  { TGenerateDataForm }

  TGenerateDataForm = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    DBMemo1: TDBMemo;
    fldSelAll: TAction;
    fldUnSelAll: TAction;
    ActionList1: TActionList;
    ButtonPanel1: TButtonPanel;
    dsFields: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    ProgressBar1: TProgressBar;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RxDateEdit1: TRxDateEdit;
    RxDateEdit2: TRxDateEdit;
    RxDBGrid1: TRxDBGrid;
    rxFields: TRxMemoryData;
    rxFieldsCHEKED: TBooleanField;
    rxFieldsDataGenAsGUID: TBooleanField;
    rxFieldsDataGenAutoIncCurrent: TLongintField;
    rxFieldsDataGenAutoIncStart: TLongintField;
    rxFieldsDataGenAutoIncStep: TLongintField;
    rxFieldsDataGenDateIncludeTime: TBooleanField;
    rxFieldsDataGenDateMax: TDateTimeField;
    rxFieldsDataGenDateMin: TDateTimeField;
    rxFieldsDataGenExtFieldName: TStringField;
    rxFieldsDataGenExtRecordCount: TLongintField;
    rxFieldsDataGenExtTableName: TStringField;
    rxFieldsDataGenIntMax: TLongintField;
    rxFieldsDataGenIntMin: TLongintField;
    rxFieldsDataGenSimpleList: TMemoField;
    rxFieldsDataGenStrEndChar: TStringField;
    rxFieldsDataGenStrMaxLen: TLongintField;
    rxFieldsDataGenStrMinLen: TLongintField;
    rxFieldsDataGenStrStartChar: TStringField;
    rxFieldsDataGenType: TLongintField;
    rxFieldsFieldName: TStringField;
    rxFieldsFieldType: TStringField;
    rxFieldsFieldTypeInt: TLongintField;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    SpinEdit9: TSpinEdit;
    procedure CheckBox1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure fldSelAllExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup2Change(Sender: TObject);
    procedure rxFieldsAfterScroll(DataSet: TDataSet);
    procedure rxFieldsBeforeScroll(DataSet: TDataSet);
  private
    FTable: TDBTableObject;
    FLockCount:Integer;
    procedure LockSave;
    procedure UnLockSave;
    procedure Localize;
    procedure LoadTableInfo;
    procedure UpdateEditControl;
    procedure SaveEditData;
    procedure UpdateRadioGroup2;
    ///
    procedure InitWrite;
    procedure DoneWrite;
    procedure WriteStartTran;
    procedure WriteCommitTran;
    procedure WriteCommand(S:string);
    function MakeValue:string;
  public
    constructor CreateGenerateDataForm(ATable:TDBTableObject);
    function SaveData:boolean;
  end;


procedure ShowGenerateDataForm(ATable:TDBTableObject);
implementation
uses Math, rxdbutils, sqlObjects, IBManMainUnit, StrUtils, fbmStrConstUnit;

procedure ShowGenerateDataForm(ATable: TDBTableObject);
var
  GenerateDataForm: TGenerateDataForm;
begin
  GenerateDataForm:=TGenerateDataForm.CreateGenerateDataForm(ATable);
  GenerateDataForm.ShowModal;
  GenerateDataForm.Free;
end;

{$R *.lfm}

{ TGenerateDataForm }

procedure TGenerateDataForm.fldSelAllExecute(Sender: TObject);
begin
  FillValueForField(rxFieldsCHEKED, ((Sender as TComponent).Tag > 0));
end;

procedure TGenerateDataForm.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  if ModalResult = mrOK then
    CanClose:=SaveData;
end;

procedure TGenerateDataForm.ComboBox1Change(Sender: TObject);
var
  D: TObject;
begin
  ComboBox2.Items.Clear;
  if (ComboBox1.ItemIndex>=0) and (ComboBox1.ItemIndex<ComboBox1.Items.Count) then
  begin
    D:=ComboBox1.Items.Objects[ComboBox1.ItemIndex];
    if D is TDBDataSetObject then
    begin
      if TDBDataSetObject(D).Fields.Count = 0 then
        TDBDataSetObject(D).RefreshFieldList;
      TDBDataSetObject(D).Fields.SaveToStrings(ComboBox2.Items);
    end;
  end;
  SaveEditData;
end;

procedure TGenerateDataForm.ComboBox2Change(Sender: TObject);
begin
  SaveEditData;
end;

procedure TGenerateDataForm.CheckBox1Change(Sender: TObject);
begin
  ComboBox1Change(Sender);
  Label10.Enabled:=not CheckBox1.Checked;
  Label11.Enabled:=Label10.Enabled;
  Label12.Enabled:=Label10.Enabled;
  Label13.Enabled:=Label10.Enabled;
  SpinEdit8.Enabled:=Label10.Enabled;
  SpinEdit9.Enabled:=Label10.Enabled;
  ComboBox3.Enabled:=Label10.Enabled;
  ComboBox4.Enabled:=Label10.Enabled;
end;

procedure TGenerateDataForm.FormCreate(Sender: TObject);
begin
  SpinEdit3.Value:=-MaxInt-1;
  SpinEdit4.Value:=MaxInt;
end;

procedure TGenerateDataForm.RadioGroup2Change(Sender: TObject);
begin
  SaveEditData;
  if rxFields.State <> dsBrowse then
    rxFields.Post;

  UpdateEditControl;
end;

procedure TGenerateDataForm.rxFieldsAfterScroll(DataSet: TDataSet);
begin
  UpdateRadioGroup2;
  UpdateEditControl;
end;

procedure TGenerateDataForm.rxFieldsBeforeScroll(DataSet: TDataSet);
begin
  //
end;

procedure TGenerateDataForm.LockSave;
begin
  Inc(FLockCount)
end;

procedure TGenerateDataForm.UnLockSave;
begin
  if FLockCount>0 then
    Dec(FLockCount);
end;

procedure TGenerateDataForm.Localize;
begin
  fldSelAll.Caption:=sSelectAll;
  fldUnSelAll.Caption:=sUnselectAll;
end;

procedure TGenerateDataForm.LoadTableInfo;
var
  F: TDBField;
begin
  LockSave;
  rxFields.BeforeScroll:=nil;
  rxFields.AfterScroll:=nil;

  rxFields.DisableControls;
  rxFields.CloseOpen;
  if not Assigned(FTable) then Exit;
  for F in FTable.Fields do
  begin
    rxFields.Append;
    rxFieldsCHEKED.AsBoolean:=false;
    rxFieldsFieldName.AsString:=F.FieldName;
    rxFieldsFieldType.AsString:=F.TypeStr;
    rxFieldsFieldTypeInt.AsInteger:=Ord(F.FieldTypeDB);
    rxFieldsDataGenType.AsInteger:=0;

    rxFieldsDataGenIntMin.AsInteger:=-MaxInt-1;
    rxFieldsDataGenIntMax.AsInteger:=MaxInt;

    rxFieldsDataGenDateMin.AsDateTime:=IncMonth(Date, -1);
    rxFieldsDataGenDateMax.AsDateTime:=IncMonth(Date, 1);

    rxFieldsDataGenAutoIncStart.AsInteger:=0;
    rxFieldsDataGenAutoIncStep.AsInteger:=1;
    rxFields.Post;
  end;

  rxFields.First;
  rxFields.EnableControls;

  rxFields.BeforeScroll:=@rxFieldsBeforeScroll;
  rxFields.AfterScroll:=@rxFieldsAfterScroll;

  if Assigned(FTable) then
    FTable.OwnerDB.FillListForNames(ComboBox1.Items, [okTable, okForeignTable, okView, okMaterializedView]);

  UpdateEditControl;
  UnLockSave;
end;

procedure TGenerateDataForm.UpdateEditControl;

procedure DoUpdate(P, SP:TGroupBox);
begin
  P.Visible:=P = SP;
  if P.Visible then
  begin
    P.AnchorSideTop.Control:=RadioGroup2;
    P.AnchorSideLeft.Control:=RadioGroup2;
    P.AnchorSideRight.Control:=RadioGroup2;
  end;
end;

var
  G: TGroupBox;
begin
  LockSave;
  RadioGroup2.ItemIndex:=rxFieldsDataGenType.AsInteger;
  case rxFieldsDataGenType.AsInteger of
    0:if TFieldType(rxFieldsFieldTypeInt.AsInteger) in StringTypes then
        G:=GroupBox5
      else
      if TFieldType(rxFieldsFieldTypeInt.AsInteger) in DataTimeTypes then
        G:=GroupBox6
      else
        G:=GroupBox1;
    1:G:=GroupBox2;
    2:G:=GroupBox3;
    3:G:=GroupBox4;
  else
    G:=nil;
  end;
  DoUpdate(GroupBox1, G);
  DoUpdate(GroupBox2, G);
  DoUpdate(GroupBox3, G);
  DoUpdate(GroupBox4, G);
  DoUpdate(GroupBox5, G);
  DoUpdate(GroupBox6, G);

  if GroupBox1.Visible then
  begin
    SpinEdit3.Value:=rxFieldsDataGenIntMin.AsInteger;
    SpinEdit4.Value:=rxFieldsDataGenIntMax.AsInteger;
  end
  else
  if GroupBox2.Visible then
  begin
    ComboBox1.Text:=rxFieldsDataGenExtTableName.AsString;
    ComboBox2.Text:=rxFieldsDataGenExtFieldName.AsString;
    SpinEdit5.Value:=rxFieldsDataGenExtRecordCount.AsInteger;
  end
  else
{  if GroupBox3.Visible then
  begin
  end
  else}
  if GroupBox4.Visible then
  begin
    SpinEdit6.Value:=rxFieldsDataGenAutoIncStart.AsInteger;
    SpinEdit7.Value:=rxFieldsDataGenAutoIncStep.AsInteger;
  end
  else
  if GroupBox5.Visible then
  begin
    CheckBox1.Checked:=rxFieldsDataGenAsGUID.AsBoolean;
  end
  else
  if GroupBox6.Visible then
  begin
    RxDateEdit1.Date:=rxFieldsDataGenDateMin.AsDateTime;
    RxDateEdit2.Date:=rxFieldsDataGenDateMax.AsDateTime;
    CheckBox2.Checked:=rxFieldsDataGenDateIncludeTime.AsBoolean;
  end;
  UnLockSave;
end;

procedure TGenerateDataForm.SaveEditData;
begin
  if FLockCount<>0 then Exit;

  if rxFields.State <> dsEdit then
    rxFields.Edit;

  rxFieldsDataGenType.AsInteger:=RadioGroup2.ItemIndex;

  if GroupBox1.Visible then
  begin
    rxFieldsDataGenIntMin.AsInteger := SpinEdit3.Value;
    rxFieldsDataGenIntMax.AsInteger := SpinEdit4.Value;
  end
  else
  if GroupBox2.Visible then
  begin
    rxFieldsDataGenExtTableName.AsString    := ComboBox1.Text;
    rxFieldsDataGenExtFieldName.AsString    := ComboBox2.Text;
    rxFieldsDataGenExtRecordCount.AsInteger := SpinEdit5.Value;
  end
  else
{  if GroupBox3.Visible then
  begin
  end
  else}
  if GroupBox4.Visible then
  begin
    rxFieldsDataGenAutoIncStart.AsInteger := SpinEdit6.Value;
    rxFieldsDataGenAutoIncStep.AsInteger  := SpinEdit7.Value;
  end
  else
  if GroupBox5.Visible then
  begin
    rxFieldsDataGenAsGUID.AsBoolean := CheckBox1.Checked;
  end
  else
  if GroupBox6.Visible then
  begin
    rxFieldsDataGenDateMin.AsDateTime        := RxDateEdit1.Date;
    rxFieldsDataGenDateMax.AsDateTime        := RxDateEdit2.Date;
    rxFieldsDataGenDateIncludeTime.AsBoolean := CheckBox2.Checked;
  end;
end;

procedure TGenerateDataForm.UpdateRadioGroup2;
begin
  RadioGroup2.Items.BeginUpdate;
  RadioGroup2.Items.Clear;
  if TFieldType(rxFieldsFieldTypeInt.AsInteger) in IntegerDataTypes then
  begin
    RadioGroup2.Items.Add('Generate randomly');
    RadioGroup2.Items.Add('Get from another table');
    RadioGroup2.Items.Add('Get from list');
    RadioGroup2.Items.Add('Autoincrement');
  end
  else
  begin
    RadioGroup2.Items.Add('Generate randomly');
    RadioGroup2.Items.Add('Get from another table');
    RadioGroup2.Items.Add('Get from list');
  end;
  RadioGroup2.Items.EndUpdate;
end;

procedure TGenerateDataForm.InitWrite;
begin
  fbManagerMainForm.tlsSqlScript.Execute;
end;

procedure TGenerateDataForm.DoneWrite;
begin

end;

procedure TGenerateDataForm.WriteStartTran;
begin
  WriteCommand('begin');
end;

procedure TGenerateDataForm.WriteCommitTran;
begin
  WriteCommand('commit');
end;

procedure TGenerateDataForm.WriteCommand(S: string);
begin
  FBMSqlScripForm.AddLineText(S + ';');
end;

function TGenerateDataForm.MakeValue: string;
var
  FT: TFieldType;
  G: TGUID;
begin
  Result:='';
  FT:=TFieldType(rxFieldsFieldTypeInt.AsInteger);
  if FT in IntegerDataTypes then
  begin
    case rxFieldsDataGenType.AsInteger of
      //1: //Get from table
      //2: //Get from list
      3:begin
          //AutoInc
          rxFields.Edit;
          rxFieldsDataGenAutoIncCurrent.AsInteger:=rxFieldsDataGenAutoIncCurrent.AsInteger + rxFieldsDataGenAutoIncStep.AsInteger;
          rxFields.Post;
          MakeValue:=IntToStr(rxFieldsDataGenAutoIncCurrent.AsInteger);
        end;
    else
      //0 - random
      Result:=IntToStr((RandomRange(rxFieldsDataGenIntMin.AsInteger, rxFieldsDataGenIntMax.AsInteger)));
    end
  end
  else
  if FT in StringTypes then
  begin
    //case rxFieldsDataGenType.AsInteger of
      //1: //Get from table
      //2: //Get from list
    //else
      //0 - random
      CreateGUID(G);
      Result:=GUIDToString(G);
    //end
  end;

  if FT in StringTypes + DataTimeTypes then
    Result:=QuotedStr(Result);
end;

constructor TGenerateDataForm.CreateGenerateDataForm(ATable: TDBTableObject);
begin
  inherited Create(Application);
  FLockCount:=0;
  Localize;
  FTable:=ATable;
  LoadTableInfo;
end;

function TGenerateDataForm.SaveData: boolean;
var
  i: Integer;
  SFields, SValues: String;
begin
  Result:=true;
  SFields:='';
  if rxFields.State <> dsBrowse then rxFields.Post;
  rxFields.First;
  while not rxFields.EOF do
  begin
    if rxFieldsCHEKED.AsBoolean then
    begin
      if SFields<>'' then SFields:=SFields + ', ';
      SFields:=SFields + rxFieldsFieldName.AsString;
    end;
    rxFields.Edit;
    rxFieldsDataGenAutoIncCurrent.AsInteger:=rxFieldsDataGenAutoIncStart.AsInteger;
    rxFields.Post;
    rxFields.Next;
  end;

  if SFields <> '' then
  begin
    InitWrite;
    ProgressBar1.Position:=0;
    ProgressBar1.Max:=SpinEdit1.Value;
    WriteStartTran;
    rxFields.DisableControls;
    rxFields.AfterScroll:=nil;
    rxFields.BeforeScroll:=nil;
    rxFields.First;

    for i:=1 to SpinEdit1.Value do
    begin
      rxFields.First;
      SValues:='';
      while not rxFields.EOF do
      begin
        if rxFieldsCHEKED.AsBoolean then
        begin
          if SValues<>'' then SValues:=SValues + ', ';
          SValues:=SValues + MakeValue;
        end;
        rxFields.Next;
      end;
      WriteCommand('insert into ' +FTable.CaptionFullPatch+ LineEnding + '  (' + SFields +')' + LineEnding + '  values(' + SValues+')');

      if (SpinEdit2.Value>0) and (i mod SpinEdit2.Value = 0) then
      begin
        WriteCommitTran;
        WriteStartTran;
      end;
      ProgressBar1.Position:=i;
    end;

    rxFields.AfterScroll:=@rxFieldsAfterScroll;
    rxFields.BeforeScroll:=@rxFieldsBeforeScroll;
    rxFields.EnableControls;
    WriteCommitTran;
    DoneWrite;
    Result:=true;
  end;
end;

end.

