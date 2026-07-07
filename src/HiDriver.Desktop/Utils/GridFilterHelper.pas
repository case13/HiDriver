unit GridFilterHelper;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  Vcl.Controls,
  Vcl.Grids;

type
  TGridSortDirection = (gsdAscending, gsdDescending);

  TGridFilterHelper = class
  private
    FColumnFields: TDictionary<Integer, string>;
    FColumnTitles: TDictionary<Integer, string>;
    FDefaultColumnIndex: Integer;
    FDefaultFilterField: string;
    FDefaultSortDirection: TGridSortDirection;
    FGrid: TStringGrid;
    FOnFilterChanged: TNotifyEvent;
    FSelectedColumnIndex: Integer;
    FSelectedFilterField: string;
    FSortDirection: TGridSortDirection;
    function CleanHeaderTitle(const ATitle: string): string;
    function DirectionPrefix: string;
    function FieldForColumn(AColumnIndex: Integer): string;
    function GetSelectedFilterField: string;
    function GetSelectedSortDirection: string;
    function GetSelectedSortField: string;
    function HasMappedColumn(AColumnIndex: Integer): Boolean;
    function HeaderTitleForColumn(AColumnIndex: Integer): string;
    procedure NotifyFilterChanged;
    procedure RestoreHeaderCaptions;
    procedure SetSelectedColumn(
      AColumnIndex: Integer;
      const AFilterField: string;
      ASortDirection: TGridSortDirection;
      ANotifyChange: Boolean);
    procedure UpdateHeaderCaptions;
  public
    constructor Create(
      AGrid: TStringGrid;
      const ADefaultFilterField: string;
      ADefaultColumnIndex: Integer = -1;
      ADefaultSortDirection: TGridSortDirection = gsdAscending);
    destructor Destroy; override;
    procedure ApplySelectedHeaderStyle;
    procedure ClearMappings;
    procedure EnsureSelectedColumnExists;
    procedure HandleGridDrawCell(
      Sender: TObject;
      ACol,
      ARow: Longint;
      Rect: TRect;
      State: TGridDrawState);
    procedure HandleGridMouseDown(
      Sender: TObject;
      Button: TMouseButton;
      Shift: TShiftState;
      X,
      Y: Integer);
    procedure MapColumn(
      AColumnIndex: Integer;
      const AFilterField: string);
    procedure SelectColumn(AColumnIndex: Integer);
    procedure SelectDefaultColumn;
    property OnFilterChanged: TNotifyEvent
      read FOnFilterChanged write FOnFilterChanged;
    property SelectedColumnIndex: Integer read FSelectedColumnIndex;
    property SelectedFilterField: string read GetSelectedFilterField;
    property SelectedSortDirection: string read GetSelectedSortDirection;
    property SelectedSortField: string read GetSelectedSortField;
    property SortDirection: TGridSortDirection read FSortDirection;
  end;

implementation

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Graphics,
  Winapi.Windows;

const
  ASCENDING_HEADER_MARKER = $A71B;
  DESCENDING_HEADER_MARKER = $A71C;

procedure TGridFilterHelper.ApplySelectedHeaderStyle;
begin
  UpdateHeaderCaptions;
  if Assigned(FGrid) then
    FGrid.Invalidate;
end;

function TGridFilterHelper.CleanHeaderTitle(const ATitle: string): string;
begin
  Result := ATitle;
  while (Result <> '') and
    ((Result[1] = Char(ASCENDING_HEADER_MARKER)) or
      (Result[1] = Char(DESCENDING_HEADER_MARKER))) do
    Delete(Result, 1, 1);

  Result := TrimLeft(Result);
end;

procedure TGridFilterHelper.ClearMappings;
begin
  RestoreHeaderCaptions;
  FColumnFields.Clear;
  FColumnTitles.Clear;
  FSelectedColumnIndex := -1;
  FSelectedFilterField := '';
  FSortDirection := FDefaultSortDirection;
  ApplySelectedHeaderStyle;
end;

constructor TGridFilterHelper.Create(
  AGrid: TStringGrid;
  const ADefaultFilterField: string;
  ADefaultColumnIndex: Integer;
  ADefaultSortDirection: TGridSortDirection);
begin
  inherited Create;
  if not Assigned(AGrid) then
    raise EArgumentNilException.Create('Grid is required.');

  FGrid := AGrid;
  FDefaultFilterField := ADefaultFilterField;
  FDefaultColumnIndex := ADefaultColumnIndex;
  FDefaultSortDirection := ADefaultSortDirection;
  FSelectedColumnIndex := -1;
  FSelectedFilterField := '';
  FSortDirection := FDefaultSortDirection;
  FColumnFields := TDictionary<Integer, string>.Create;
  FColumnTitles := TDictionary<Integer, string>.Create;
end;

destructor TGridFilterHelper.Destroy;
begin
  RestoreHeaderCaptions;
  FColumnTitles.Free;
  FColumnFields.Free;
  inherited;
end;

function TGridFilterHelper.DirectionPrefix: string;
begin
  if FSortDirection = gsdDescending then
    Result := string(Char(DESCENDING_HEADER_MARKER))
  else
    Result := string(Char(ASCENDING_HEADER_MARKER));
end;

procedure TGridFilterHelper.EnsureSelectedColumnExists;
begin
  if not Assigned(FGrid) then
    Exit;

  if (FSelectedColumnIndex < 0) or
    (FSelectedColumnIndex >= FGrid.ColCount) or
    not HasMappedColumn(FSelectedColumnIndex) then
    SelectDefaultColumn
  else
    ApplySelectedHeaderStyle;
end;

function TGridFilterHelper.FieldForColumn(AColumnIndex: Integer): string;
begin
  Result := '';
  FColumnFields.TryGetValue(AColumnIndex, Result);
end;

function TGridFilterHelper.GetSelectedFilterField: string;
begin
  Result := Trim(FSelectedFilterField);
  if Result = '' then
    Result := FDefaultFilterField;
end;

function TGridFilterHelper.GetSelectedSortDirection: string;
begin
  if FSortDirection = gsdDescending then
    Result := 'desc'
  else
    Result := 'asc';
end;

function TGridFilterHelper.GetSelectedSortField: string;
begin
  Result := GetSelectedFilterField;
end;

procedure TGridFilterHelper.HandleGridDrawCell(
  Sender: TObject;
  ACol,
  ARow: Longint;
  Rect: TRect;
  State: TGridDrawState);
var
  CellText: string;
  SavedFont: TFont;
  TextRect: TRect;
begin
  if (Sender <> FGrid) or (ARow <> 0) then
    Exit;

  SavedFont := TFont.Create;
  try
    SavedFont.Assign(FGrid.Canvas.Font);
    FGrid.Canvas.Brush.Color := FGrid.FixedColor;
    FGrid.Canvas.FillRect(Rect);
    FGrid.Canvas.Font.Assign(FGrid.Font);
    if ACol = FSelectedColumnIndex then
      FGrid.Canvas.Font.Style := FGrid.Canvas.Font.Style + [fsBold]
    else
      FGrid.Canvas.Font.Style := FGrid.Canvas.Font.Style - [fsBold];

    CellText := FGrid.Cells[ACol, ARow];
    TextRect := Rect;
    InflateRect(TextRect, -4, -1);
    DrawText(
      FGrid.Canvas.Handle,
      PChar(CellText),
      Length(CellText),
      TextRect,
      DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);
  finally
    FGrid.Canvas.Font.Assign(SavedFont);
    SavedFont.Free;
  end;
end;

procedure TGridFilterHelper.HandleGridMouseDown(
  Sender: TObject;
  Button: TMouseButton;
  Shift: TShiftState;
  X,
  Y: Integer);
var
  ColumnIndex: Integer;
  RowIndex: Integer;
begin
  if (Sender <> FGrid) or (Button <> mbLeft) then
    Exit;

  FGrid.MouseToCell(X, Y, ColumnIndex, RowIndex);
  if RowIndex = 0 then
    SelectColumn(ColumnIndex);
end;

function TGridFilterHelper.HasMappedColumn(AColumnIndex: Integer): Boolean;
begin
  Result := FColumnFields.ContainsKey(AColumnIndex);
end;

function TGridFilterHelper.HeaderTitleForColumn(
  AColumnIndex: Integer): string;
begin
  if not FColumnTitles.TryGetValue(AColumnIndex, Result) then
    if Assigned(FGrid) and
      (AColumnIndex >= 0) and
      (AColumnIndex < FGrid.ColCount) then
      Result := CleanHeaderTitle(FGrid.Cells[AColumnIndex, 0])
    else
      Result := '';
end;

procedure TGridFilterHelper.MapColumn(
  AColumnIndex: Integer;
  const AFilterField: string);
var
  HeaderTitle: string;
begin
  if AColumnIndex < 0 then
    Exit;

  FColumnFields.AddOrSetValue(AColumnIndex, Trim(AFilterField));
  if Assigned(FGrid) and
    (AColumnIndex < FGrid.ColCount) and
    (not FColumnTitles.ContainsKey(AColumnIndex)) then
  begin
    HeaderTitle := CleanHeaderTitle(FGrid.Cells[AColumnIndex, 0]);
    FColumnTitles.AddOrSetValue(AColumnIndex, HeaderTitle);
  end;
end;

procedure TGridFilterHelper.NotifyFilterChanged;
begin
  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Self);
end;

procedure TGridFilterHelper.SelectColumn(AColumnIndex: Integer);
var
  FilterField: string;
  NewSortDirection: TGridSortDirection;
begin
  if not Assigned(FGrid) then
    Exit;

  if (AColumnIndex < 0) or
    (AColumnIndex >= FGrid.ColCount) or
    not HasMappedColumn(AColumnIndex) then
    Exit;

  FilterField := FieldForColumn(AColumnIndex);
  if (FSelectedColumnIndex = AColumnIndex) and
    SameText(FSelectedFilterField, FilterField) then
  begin
    if FSortDirection = gsdAscending then
      NewSortDirection := gsdDescending
    else
      NewSortDirection := gsdAscending;
  end
  else
    NewSortDirection := gsdAscending;

  SetSelectedColumn(
    AColumnIndex,
    FilterField,
    NewSortDirection,
    True);
end;

procedure TGridFilterHelper.SelectDefaultColumn;
var
  ColumnIndex: Integer;
begin
  if HasMappedColumn(FDefaultColumnIndex) then
  begin
    SetSelectedColumn(
      FDefaultColumnIndex,
      FieldForColumn(FDefaultColumnIndex),
      FDefaultSortDirection,
      False);
    Exit;
  end;

  if Assigned(FGrid) then
    for ColumnIndex := 0 to FGrid.ColCount - 1 do
      if SameText(FieldForColumn(ColumnIndex), FDefaultFilterField) then
      begin
        SetSelectedColumn(
          ColumnIndex,
          FieldForColumn(ColumnIndex),
          FDefaultSortDirection,
          False);
        Exit;
      end;

  FSelectedColumnIndex := -1;
  FSelectedFilterField := FDefaultFilterField;
  FSortDirection := FDefaultSortDirection;
  ApplySelectedHeaderStyle;
end;

procedure TGridFilterHelper.RestoreHeaderCaptions;
var
  ColumnIndex: Integer;
  HeaderTitle: string;
begin
  if not Assigned(FGrid) then
    Exit;

  for ColumnIndex in FColumnTitles.Keys do
    if (ColumnIndex >= 0) and (ColumnIndex < FGrid.ColCount) then
    begin
      HeaderTitle := HeaderTitleForColumn(ColumnIndex);
      FGrid.Cells[ColumnIndex, 0] := HeaderTitle;
    end;
end;

procedure TGridFilterHelper.SetSelectedColumn(
  AColumnIndex: Integer;
  const AFilterField: string;
  ASortDirection: TGridSortDirection;
  ANotifyChange: Boolean);
var
  Changed: Boolean;
begin
  Changed := (FSelectedColumnIndex <> AColumnIndex) or
    not SameText(FSelectedFilterField, AFilterField) or
    (FSortDirection <> ASortDirection);

  FSelectedColumnIndex := AColumnIndex;
  FSelectedFilterField := AFilterField;
  FSortDirection := ASortDirection;
  ApplySelectedHeaderStyle;

  if ANotifyChange and Changed then
    NotifyFilterChanged;
end;

procedure TGridFilterHelper.UpdateHeaderCaptions;
var
  ColumnIndex: Integer;
  HeaderTitle: string;
begin
  if not Assigned(FGrid) then
    Exit;

  for ColumnIndex in FColumnFields.Keys do
    if (ColumnIndex >= 0) and (ColumnIndex < FGrid.ColCount) then
    begin
      HeaderTitle := HeaderTitleForColumn(ColumnIndex);
      if ColumnIndex = FSelectedColumnIndex then
        FGrid.Cells[ColumnIndex, 0] := DirectionPrefix + HeaderTitle
      else
        FGrid.Cells[ColumnIndex, 0] := HeaderTitle;
    end;
end;

end.
