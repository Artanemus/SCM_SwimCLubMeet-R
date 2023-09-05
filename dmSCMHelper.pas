unit dmSCMHelper;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math,
  System.IniFiles, System.Variants, System.UITypes, Vcl.StdCtrls, Vcl.Dialogs,
  Vcl.Forms, FireDAC.Comp.Client, Winapi.Windows,
  SCMUtility, SCMDefines, dmSCM;

type
  TSCMHelper = class helper for TSCM
    function NOM_ClearLane(aMemberID, aEventID: integer;
      DoExclude: Boolean = true): integer;

    // D E L E T E
    function NOM_DeleteALLExclude(aEventID: integer;
      DoExclude: Boolean = true): integer;
    function NOM_DeleteExclude(aMemberID, aEventID: integer;
      DoExclude: Boolean = true): integer;

    function NOM_HeatStatusID(aMemberID, aEventID: integer): integer;
    function NOM_IsMemberInEvent(aMemberID, aEventID: integer): Boolean;
    function NOM_IsMemberNominated(aMemberID, aEventID: integer): Boolean;
    function NOM_IsNomineeInEvent(aNomineeID: integer): integer;
    function NOM_NominateMember(aMemberID, aEventID: integer;
      DoExclude: Boolean = true): integer;
    function NOM_StrikeLane(aMemberID, aEventID: integer;
      DoExclude: Boolean = true): integer;
    function NOM_SwimmerID(aMemberID, aEventID: integer): integer;
    function NOM_UnNominateMember(aMemberID, aEventID: integer;
      DoExclude: Boolean = true): integer;

    // S W I M M E R S .
    function Swimmer_ClearLane(aSwimmerID: integer;
      aEventType: TEventType): integer;
    function Swimmer_HeatStatusID(aSwimmerID: integer;
      aEventType: TEventType): integer;
    function Swimmer_StrikeLane(aSwimmerID: integer;
      aEventType: TEventType): integer;
    function Swimmer_SwimmerID(aSwimmerID: integer;
      aEventType: TEventType): integer;

    // L A N E S .  05.09.2023
    function Lane_Count(aHeatID: integer): integer;
    function Lane_Trim(aHeatID: integer): integer;
    function Lane_Delete(aHeatID: integer): integer;
    function Lane_Insert(aHeatID: integer): integer;
    function Lane_Last(aHeatID: integer): integer;
    procedure Lane_Renumber(aHeatID: integer);

  end;

implementation

{ TSCMHelper }

function TSCMHelper.Lane_Count(aHeatID: integer): integer;
var
  NumOfLanes: integer;
  SQL: string;
  v: variant;
  aEventType: TEventType;
begin
  result := 0;
  if not SCMActive then exit;
  if aHeatID = 0 then exit;
  if Heat_SessionIsLocked(aHeatID) then exit;

  aEventType := Heat_EventType(aHeatID);
  if aEventType = etINDV then
  begin
    // Count number of lanes ....
    SQL := 'SELECT Count(EntrantID) FROM SwimClubMeet.dbo.Entrant ' +
      'WHERE Entrant.HeatID = :HEATID';
    v := scmConnection.ExecSQLScalar(SQL, [aHeatID]);
    if not VarIsNull(v) or not VarIsEmpty(v) then result := v;
  end
  else if aEventType = etTEAM then
  begin
    // Count number of lanes ....
    SQL := 'SELECT Count(TeamEntrantID) FROM SwimClubMeet.dbo.Team ' +
      'INNER JOIN TeamEntrant ON Team.TeamID = TeamEntrant.TeamID ' +
      'WHERE Team.HeatID = :HEATID';
    v := scmConnection.ExecSQLScalar(SQL, [aHeatID]);
    if not VarIsNull(v) or not VarIsEmpty(v) then result := v;
  end;
end;

function TSCMHelper.Lane_Delete(aHeatID: integer): integer;
begin

end;

function TSCMHelper.Lane_Insert(aHeatID: integer): integer;
begin

end;

function TSCMHelper.Lane_Last(aHeatID: integer): integer;
var
  aEventType: TEventType;
begin
  // EventType
  aEventType := Heat_EventType(aHeatID);
  if aEventType = etINDV then
  begin

  end
  else if aEventType = etTEAM then
  begin

  end;
end;

procedure TSCMHelper.Lane_Renumber(aHeatID: integer);
var
  aEventType: TEventType;
begin
  // EventType
  aEventType := Heat_EventType(aHeatID);
  if aEventType = etINDV then
  begin

  end
  else if aEventType = etTEAM then
  begin

  end;

end;

function TSCMHelper.Lane_Trim(aHeatID: integer): integer;
var
  NumOfLanes, Lanes, i: integer;
  aEventType: TEventType;
begin
  if not SCMActive then exit;
  if aHeatID = 0 then exit;
  if Heat_SessionIsLocked(aHeatID) then exit;
  // number of lanes in club pool.
  NumOfLanes := SwimClub_NumberOfLanes;
  Lanes := 0;
  // EventType
  aEventType := Heat_EventType(aHeatID);
  if aEventType = etINDV then
  begin
    if Lanes > NumOfLanes then
    begin
      // too many lanes
      Lane_Delete(aHeatID);
    end
    else if Lanes < NumOfLanes then
    begin
      // need more lanes
      for i := 1 to (NumOfLanes - Lanes) do Lane_Insert(aHeatID);
    end;
    Lane_Renumber(aHeatID);
  end
  else if aEventType = etTEAM then
  begin
    if Lanes > NumOfLanes then
    begin
      // too many lanes
      Lane_Delete(aHeatID);
    end
    else if Lanes < NumOfLanes then
    begin
      // need more lanes
      for i := 1 to (NumOfLanes - Lanes) do Lane_Insert(aHeatID);
    end;
    Lane_Renumber(aHeatID);
  end;
end;

function TSCMHelper.NOM_ClearLane(aMemberID, aEventID: integer;
  DoExclude: Boolean): integer;
var
  aHeatStatusID, aSwimmerID: integer;
  aEventType: TEventType;
begin
  result := 0;
  if not SCMActive then
    exit;
  if Event_SessionIsLocked(aEventID) then
    exit;
  aSwimmerID := NOM_SwimmerID(aMemberID, aEventID);
  // Member wasn't given a lane. Nothing to clear.
  if aSwimmerID = 0 then
    exit;
  aEventType := Event_EventType(aEventID);
  // RTNs zero if no heats or the nominee wasn't given a lane.
  aHeatStatusID := NOM_HeatStatusID(aMemberID, aEventID);
  // The nominee was given a lane. Heat is 'open' or force delete.
  if (aHeatStatusID = 1) or (DoExclude = false) then
  begin
    // Remove swimmer from lane.
    if (aEventType = etINDV) then
      Entrant_ClearLaneExclude(aSwimmerID, DoExclude)
    else if (aEventType = etTeam) then
      Team_ClearLaneExclude(aSwimmerID, DoExclude);
    result := 1;
  end;
end;

function TSCMHelper.NOM_DeleteALLExclude(aEventID: integer;
  DoExclude: Boolean): integer;
var
  qry: TFDQuery;
  rows, aMemberID: integer;
begin
  result := 0;
  rows := 0;
  qry := TFDQuery.Create(self);
  qry.Connection := scmConnection;
  qry.SQL.Text :=
    'SELECT [Nominee].[MemberID]  FROM [SwimClubMeet].[dbo].[Nominee] ' +
    'WHERE [Nominee].EventID = ' + IntToStr(aEventID);
  qry.IndexFieldNames := 'NomineeID';
  qry.Open;
  if qry.Active then
  begin
    while not qry.Eof do
    begin
      aMemberID := qry.FieldByName('aMemberID').AsInteger;
      rows := rows + NOM_DeleteExclude(aMemberID, aEventID, DoExclude);
      qry.Next;
    end;
    if rows > 0 then result := rows;
  end;
  qry.Close;
  qry.Free;
end;

function TSCMHelper.NOM_DeleteExclude(aMemberID, aEventID: integer;
  DoExclude: Boolean = true): integer;
var
  SQL: string;
  rows: integer;
begin
  result := 0;
  if not SCMActive then
    exit;
  if Event_SessionIsLocked(aEventID) then
    exit;
  // If the nominee was given a lane - remove swimmer from lane.
  rows := NOM_ClearLane(aMemberID, aEventID, DoExclude);
  // Assert that the member hasn't been assigned a lane.
  if not(NOM_IsMemberInEvent(aMemberID, aEventID)) or DoExclude then
  begin
    // FINALLY DELETE Nomination..
    SQL := 'DELETE FROM SwimClubMeet.[dbo].[Nominee] ' +
      'WHERE MemberID = :MemberID AND EventID = :EventID;';
    rows := scmConnection.ExecSQL(SQL, [aMemberID, aEventID]);
    if (rows > 0) then
      result := rows;
  end;
end;

function TSCMHelper.NOM_HeatStatusID(aMemberID, aEventID: integer): integer;
var
  SQL: string;
  v: variant;
  aEventType: TEventType;
begin
  result := 0;
  if not SCMActive then
    exit;
  aEventType := Event_EventType(aEventID);
  if (aEventType = etINDV) then
  begin
    SQL := 'SELECT [Event].[EventID] ' + 'FROM [SwimClubMeet].[dbo].[Nominee] '
      + 'INNER JOIN Event ON [Nominee].EventID = Event.EventID ' +
      'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
      'INNER JOIN Entrant ON [HeatIndividual].HeatID = Entrant.HeatID ' +
      'WHERE Entrant.MemberID = :aMemberID';
    v := scmConnection.ExecSQLScalar(SQL, [aMemberID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
    begin
      result := v;
    end;
  end
  else if (aEventType = etTeam) then
  begin
    SQL := 'SELECT [Event].[EventID] ' + 'FROM [SwimClubMeet].[dbo].[Nominee] '
      + 'INNER JOIN Event ON [Nominee].EventID = Event.EventID ' +
      'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
      'INNER JOIN Team ON HeatIndividual.HeatID = Team.HeatID ' +
      'INNER JOIN TeamEntrant ON [Team].TeamID = TeamEntrant.HeatID ' +
      'WHERE TeamEntrant.MemberID = :aMemberID';
    v := scmConnection.ExecSQLScalar(SQL, [aMemberID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
      result := v;
  end;

end;

function TSCMHelper.NOM_IsMemberInEvent(aMemberID, aEventID: integer): Boolean;
begin
  result := false;
  if (NOM_SwimmerID(aMemberID, aEventID) > 0) then
    result := true;
end;

function TSCMHelper.NOM_IsMemberNominated(aMemberID, aEventID: integer)
  : Boolean;
var
  SQL: string;
  v: variant;
begin
  result := false;
  if not SCMActive then
    exit;
  SQL := 'SELECT Nominee.NomineeID FROM SwimClubMeet.dbo.Nominee ' +
    'WHERE Nominee.MemberID = :MEMBERID AND Nominee.EventID = :EVENTID;';
  v := scmConnection.ExecSQLScalar(SQL, [aMemberID, aEventID]);
  if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
    result := true;
end;

function TSCMHelper.NOM_IsNomineeInEvent(aNomineeID: integer): integer;
var
  SQL: string;
  v: variant;
begin
  result := 0; // return EntrantID. Zero indicate 'not in event'.
  if Event_IsINDV then
  begin
    SQL := 'SELECT EntrantID FROM [SwimClubMeet].[dbo].[Nominee] ' +
      'INNER JOIN [Event] ON [Event].EventID = Nominee.EventID ' +
      'INNER JOIN HeatIndividual ON HeatIndividual.EventID = [Event].EventID ' +
      'INNER JOIN Entrant ON Entrant.HeatID = HeatIndividual.HeatID ' +
      'WHERE Nominee.NomineeID = :NomineeID ' +
      'AND Nominee.MemberID = Entrant.MemberID;';
  end
  else
  begin
    SQL := 'SELECT EntrantID FROM [SwimClubMeet].[dbo].[Nominee] ' +
      'INNER JOIN [Event] ON [Event].EventID = Nominee.EventID ' +
      'INNER JOIN HeatIndividual ON HeatIndividual.EventID = [Event].EventID ' +
      'INNER JOIN Team ON Team.HeatID = HeatIndividual.HeatID ' +
      'INNER JOIN TeamEntrant ON Team.TeamID = TeamEntrant.TeamID ' +
      'WHERE Nominee.NomineeID = :NomineeID ' +
      'AND Nominee.MemberID = Entrant.MemberID;';
  end;
  v := scmConnection.ExecSQLScalar(SQL, [aNomineeID]);
  if not VarIsNull(v) or not VarIsEmpty(v) or (v <> 0) then
    result := v;
end;

function TSCMHelper.NOM_NominateMember(aMemberID, aEventID: integer;
  DoExclude: Boolean = true): integer;
var
  aHeatStatusID: integer;
  SQL: string;
begin
  result := 0;
  if not SCMActive then
    exit;
  if Event_SessionIsLocked(aEventID) then
    exit;
  if NOM_IsMemberNominated(aMemberID, aEventID) then
    exit;
  // RTNs zero if no heats or the nominee wasn't given a lane.
  aHeatStatusID := NOM_HeatStatusID(aMemberID, aEventID);
  // The nominee was given a lane. Heat is 'open' or force delete.
  if (aHeatStatusID = 1) or (DoExclude = false) then
  begin
    SQL := 'INSERT INTO [SwimClubMeet].[dbo].[Nominee] ' +
      '([AutoBuildFlag],[TTB],[PB],[MemberID],[EventID],[SeedTime]) ' +
      'VALUES (0,NULL,NULL,:MemberID,:EventID,NULL)';
    result := scmConnection.ExecSQL(SQL, [aMemberID, aEventID]);
  end;
end;

function TSCMHelper.NOM_StrikeLane(aMemberID, aEventID: integer;
  DoExclude: Boolean): integer;
begin
  result := NOM_DeleteExclude(aMemberID, aEventID, DoExclude);
end;

function TSCMHelper.NOM_SwimmerID(aMemberID, aEventID: integer): integer;
var
  SQL: string;
  v: variant;
  aEventType: TEventType;
begin
  result := 0;
  if not SCMActive then
    exit;
  aEventType := Event_EventType(aEventID);
  if (aEventType = etINDV) then
  begin
    SQL := 'SELECT TOP 1 Entrant.EntrantID FROM [SwimClubMeet].[dbo].[Event] ' +
      'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
      'INNER JOIN Entrant ON HeatIndividual.HeatID = Entrant.HeatID ' +
      'WHERE [Event].EventID = :EventID AND (Entrant.MemberID = :MemberID)';
    v := scmConnection.ExecSQLScalar(SQL, [aMemberID, aEventID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
    begin
      result := v;
      exit;
    end;
  end
  else if (aEventType = etTeam) then
  begin
    SQL := 'SELECT TOP 1 TeamEntrant.TeamEntrantID FROM [SwimClubMeet].[dbo].[Event] '
      + 'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID '
      + 'INNER JOIN Team ON HeatIndividual.HeatID = Team.HeatID ' +
      'INNER JOIN TeamEntrant ON Team.TeamID = TeamEntrant.TeamID ' +
      'WHERE [Event].EventID = :EventID AND (TeamEntrant.MemberID = :MemberID)';
    v := scmConnection.ExecSQLScalar(SQL, [aMemberID, aEventID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
      result := v;
  end;
end;

function TSCMHelper.NOM_UnNominateMember(aMemberID, aEventID: integer;
  DoExclude: Boolean = true): integer;
var
  rows, aHeatStatusID: integer;
  SQL: string;
  response: TModalResult;
begin
  result := 0;
  if not SCMActive then
    exit;
  if Event_SessionIsLocked(aEventID) then
    exit;
  if not NOM_IsMemberNominated(aMemberID, aEventID) then
    exit;
  // RTNs zero if no heats or the nominee wasn't given a lane.
  aHeatStatusID := NOM_HeatStatusID(aMemberID, aEventID);
  if not DoExclude then
  begin
    // The heat is locked - exit procedure
    if (aHeatStatusID <> 1) then
    begin
      MessageDlg('The member is nominated and has been given a lane.' +
        sLineBreak + 'The assigned heat has been set to raced or closed.' +
        sLineBreak + 'The member can''t be un-nominated.',
        TMsgDlgType.mtInformation, [mbOK], 0);
      exit;
    end;
    // preference setting - the user the option to abort procedure
    if (CheckNomination = integer(cbChecked)) then
    begin
      response := MessageDlg
        ('The member is nominated and has been given a lane.' + sLineBreak +
        'Remove the nomination AND empty the lane?', mtWarning,
        [mbYes, mbNo], 0, mbNo);
      if (response = mrNo) then
        exit;
    end;
  end;
  // The nominee was given a lane. Heat is 'open' or force delete.
  if (aHeatStatusID = 1) or (DoExclude = false) then
  begin
    rows := NOM_DeleteExclude(aMemberID, aEventID, DoExclude);
    // Entrant/TeamEntrant grid on form will need refresh.
    if (rows > 0) and (Owner is TForm) then
      PostMessage(TForm(Owner).Handle, SCM_LANEWASCLEANED, 0, 0);
    result := rows;
  end;

end;

function TSCMHelper.Swimmer_ClearLane(aSwimmerID: integer;
  aEventType: TEventType): integer;
begin

end;

function TSCMHelper.Swimmer_HeatStatusID(aSwimmerID: integer;
  aEventType: TEventType): integer;
var
  SQL: string;
  v: variant;
begin
  result := 0;
  if not SCMActive then
    exit;
  if (aEventType = etINDV) then
  begin
    SQL := 'SELECT HeatStatusID FROM [SwimClubMeet].[dbo].[HeatIndividual] ' +
      'INNER JOIN Entrant ON [HeatIndividual].[HeatID] = Entrant.HeatID ' +
      'WHERE [Entrant].[EntrantID] = :ID;';
    v := scmConnection.ExecSQLScalar(SQL, [aSwimmerID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
      result := v;
  end;
  if (aEventType = etTeam) then
  begin
    SQL := 'SELECT HeatStatusID FROM [SwimClubMeet].[dbo].[HeatIndividual] ' +
      'INNER JOIN Team ON [HeatIndividual].[HeatID] = Team.HeatID ' +
      'INNER JOIN TeamEntrant ON [Team].[TeamID] = [TeamEntrant].[TeamID] ' +
      'WHERE [TeamEntrant].[TeamEntrantID] = :ID;';
    v := scmConnection.ExecSQLScalar(SQL, [aSwimmerID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
      result := v;
  end;
end;

function TSCMHelper.Swimmer_StrikeLane(aSwimmerID: integer;
  aEventType: TEventType): integer;
begin

end;

function TSCMHelper.Swimmer_SwimmerID(aSwimmerID: integer;
  aEventType: TEventType): integer;
var
  SQL: string;
  v: variant;
begin
  result := 0;
  if not SCMActive then
    exit;
  if (aEventType = etINDV) then
  begin
    SQL := 'SELECT Entrant.MemberID FROM [SwimClubMeet].[dbo].[Entrant] ' +
      'WHERE Entrant.EntrantID = :aID';
    v := scmConnection.ExecSQLScalar(SQL, [aSwimmerID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
    begin
      result := v;
    end;
  end
  else if (aEventType = etTeam) then
  begin
    SQL := 'SELECT TeamEntrant.MemberID FROM [SwimClubMeet].[dbo].[TeamEntrant] '
      + 'WHERE TeamEntrant.TeamEntrantID = :aID';
    v := scmConnection.ExecSQLScalar(SQL, [aSwimmerID]);
    if not VarIsNull(v) and not VarIsEmpty(v) and (v > 0) then
      result := v;
  end;
end;

end.