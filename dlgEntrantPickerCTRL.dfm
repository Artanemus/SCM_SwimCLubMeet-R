object EntrantPickerCTRL: TEntrantPickerCTRL
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Quick-Pick from Active Members ,,,'
  ClientHeight = 860
  ClientWidth = 856
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    856
    860)
  PixelsPerInch = 96
  TextHeight = 19
  object Label1: TLabel
    Left = 16
    Top = 11
    Width = 52
    Height = 19
    Alignment = taRightJustify
    Caption = 'Search '
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 48
    Width = 729
    Height = 804
    Anchors = [akLeft, akTop, akBottom]
    DataSource = dsQuickPickCtrl
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -16
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = DBGrid1DblClick
    OnTitleClick = DBGrid1TitleClick
    Columns = <
      item
        Expanded = False
        FieldName = 'FName'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TTB'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'PB'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'AGE'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Gender'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'MemberID'
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'GenderID'
        Visible = False
      end>
  end
  object Nominate_Edit: TEdit
    Left = 74
    Top = 8
    Width = 223
    Height = 27
    TabOrder = 1
    OnChange = Nominate_EditChange
  end
  object btnPost: TButton
    Left = 743
    Top = 48
    Width = 106
    Height = 35
    Caption = 'Post'
    ModalResult = 1
    TabOrder = 2
    OnClick = btnPostClick
  end
  object btnCancel: TButton
    Left = 743
    Top = 89
    Width = 106
    Height = 35
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object btnToggleName: TButton
    Left = 743
    Top = 130
    Width = 106
    Height = 35
    Caption = 'Toggle Name'
    TabOrder = 4
    OnClick = btnToggleNameClick
  end
  object dsQuickPickCtrl: TDataSource
    DataSet = qryQuickPickCtrl
    Left = 151
    Top = 264
  end
  object qryQuickPickCtrl: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    FilterOptions = [foCaseInsensitive]
    Filter = '[FName] LIKE '#39'%b%'#39
    Indexes = <
      item
        Active = True
        Selected = True
        Name = 'idxMemberFName'
        Fields = 'FName'
      end
      item
        Active = True
        Name = 'idxMemberFNameDESC'
        Fields = 'FName'
        DescFields = 'FName'
        Options = [soDescNullLast, soDescending]
      end
      item
        Active = True
        Name = 'idxTTB'
        Fields = 'TTB'
      end
      item
        Active = True
        Name = 'idxTTBDESC'
        Fields = 'TTB'
        DescFields = 'TTB'
        Options = [soDescending]
      end
      item
        Active = True
        Name = 'idxPB'
        Fields = 'PB'
      end
      item
        Active = True
        Name = 'idxPBDESC'
        Fields = 'PB'
        DescFields = 'PB'
        Options = [soDescending]
      end
      item
        Active = True
        Name = 'idxAge'
        Fields = 'AGE'
      end
      item
        Active = True
        Name = 'idxAgeDESC'
        Fields = 'AGE'
        Options = [soDescNullLast, soDescending]
      end
      item
        Active = True
        Name = 'idxGender'
        Fields = 'GenderID'
      end
      item
        Active = True
        Name = 'idxGenderDESC'
        Fields = 'GenderID'
        Options = [soDescNullLast, soDescending]
      end>
    IndexName = 'idxMemberFName'
    DetailFields = 'MemberID'
    Connection = SCM.scmConnection
    FormatOptions.AssignedValues = [fvFmtDisplayTime]
    FormatOptions.FmtDisplayTime = 'nn:ss.zzz'
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    UpdateOptions.UpdateTableName = 'SwimClubMeet..Member'
    UpdateOptions.KeyFields = 'MemberID'
    SQL.Strings = (
      'USE SwimClubMeet'
      ''
      'DECLARE @EventID INT'
      'DECLARE @Algorithm INT'
      'DECLARE @DistanceID INT'
      'DECLARE @StrokeID INT'
      'DECLARE @SessionStart DATETIME'
      'DECLARE @ToggleName BIT'
      'DECLARE @Order INT'
      'DECLARE @CalcDefault INT'
      'DECLARE @BottomPercent float'
      ''
      'SET @EventID = :EVENTID;'
      'SET @Algorithm = :ALGORITHM;'
      'SET @ToggleName = :TOGGLENAME;'
      'SET @CalcDefault  = :CALCDEFAULT'
      'SET @BottomPercent = :BOTTOMPERCENT'
      ''
      'SELECT @DistanceID = Event.DistanceID'
      'FROM Event'
      'WHERE Event.EventID = @EventID;'
      ''
      'SELECT @StrokeID = Event.StrokeID'
      'FROM Event'
      'WHERE Event.EventID = @EventID;'
      ''
      'SELECT @SessionStart = Session.SessionStart'
      'FROM Event'
      'INNER JOIN Session ON Event.SessionID = Session.SessionID'
      'WHERE Event.EventID = @EventID;'
      ''
      '-- CTE '
      '-- MemberID'#39's for current selected entrants'
      'WITH tmpEntrants'
      'AS ('
      #9'SELECT Entrant.MemberID'
      ',Member.GenderID'
      #9'FROM Entrant'
      
        #9'INNER JOIN HeatIndividual ON Entrant.HeatID = HeatIndividual.He' +
        'atID'
      #9'INNER JOIN Event ON HeatIndividual.EventID = Event.EventID'
      #9'INNER JOIN Session ON Event.SessionID = Session.SessionID'
      #9'INNER JOIN Member ON Entrant.MemberID = Member.MemberID'
      #9'WHERE (HeatIndividual.EventID = @EventID)'
      #9#9'AND (Entrant.MemberID IS NOT NULL)'
      #9')'
      
        '-- ALL OTHER Members who have not been placed in the current sel' +
        'ected event'
      'SELECT Member.MemberID'
      ',Member.GenderID'
      #9',dbo.SwimmerAge(@SessionStart, Member.DOB) AS AGE'
      #9',dbo.SwimmerGenderToString(Member.MemberID) AS Gender'
      
        #9',dbo.TimeToBeat(@Algorithm, @CalcDefault, @BottomPercent, Membe' +
        'r.MemberID, @DistanceID, @StrokeID, @SessionStart) AS TTB'
      
        #9',dbo.PersonalBest(Member.MemberID, @DistanceID, @StrokeID, @Ses' +
        'sionStart) AS PB'
      #9',CASE '
      #9#9'WHEN @ToggleName = 0'
      #9#9#9'THEN SUBSTRING(CONCAT ('
      #9#9#9#9#9#9'UPPER([LastName])'
      #9#9#9#9#9#9','#39', '#39
      #9#9#9#9#9#9',[FirstName]'
      #9#9#9#9#9#9'), 0, 30)'
      #9#9'WHEN @ToggleName = 1'
      #9#9#9'THEN SUBSTRING(CONCAT ('
      #9#9#9#9#9#9'[FirstName]'
      #9#9#9#9#9#9','#39', '#39
      #9#9#9#9#9#9',UPPER([LastName])'
      #9#9#9#9#9#9'), 0, 48)'
      #9#9'END AS FName'
      'FROM Member'
      
        'LEFT OUTER JOIN tmpEntrants ON tmpEntrants.MemberID = Member.Mem' +
        'berID'
      'WHERE tmpEntrants.MemberID IS NULL'
      #9'AND Member.IsActive = 1')
    Left = 152
    Top = 192
    ParamData = <
      item
        Name = 'EVENTID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 350
      end
      item
        Name = 'ALGORITHM'
        DataType = ftInteger
        ParamType = ptInput
        Value = 2
      end
      item
        Name = 'TOGGLENAME'
        DataType = ftBoolean
        ParamType = ptInput
        Value = True
      end
      item
        Name = 'CALCDEFAULT'
        DataType = ftInteger
        ParamType = ptInput
        Value = 1
      end
      item
        Name = 'BOTTOMPERCENT'
        DataType = ftFloat
        ParamType = ptInput
        Value = 50.000000000000000000
      end>
    object qryQuickPickCtrlFName: TWideStringField
      DisplayLabel = 'Member'#39's Name'
      DisplayWidth = 30
      FieldName = 'FName'
      Origin = 'FName'
      ReadOnly = True
      Size = 48
    end
    object qryQuickPickCtrlTTB: TTimeField
      Alignment = taCenter
      DisplayLabel = 'TimeToBeat'
      DisplayWidth = 12
      FieldName = 'TTB'
      Origin = 'TTB'
      ReadOnly = True
      DisplayFormat = 'nn:ss.zzz'
    end
    object qryQuickPickCtrlPB: TTimeField
      Alignment = taCenter
      DisplayLabel = 'Personal Best'
      DisplayWidth = 12
      FieldName = 'PB'
      Origin = 'PB'
      ReadOnly = True
      DisplayFormat = 'nn:ss.zzz'
    end
    object qryQuickPickCtrlAGE: TIntegerField
      Alignment = taCenter
      DisplayLabel = '  AGE'
      DisplayWidth = 5
      FieldName = 'AGE'
      Origin = 'AGE'
      ReadOnly = True
      DisplayFormat = '##0'
    end
    object qryQuickPickCtrlGender: TWideStringField
      Alignment = taCenter
      DisplayWidth = 9
      FieldName = 'Gender'
      Origin = 'Gender'
      ReadOnly = True
      Size = 2
    end
    object qryQuickPickCtrlMemberID: TFDAutoIncField
      FieldName = 'MemberID'
      Origin = 'MemberID'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryQuickPickCtrlGenderID: TIntegerField
      FieldName = 'GenderID'
      Origin = 'GenderID'
    end
  end
  object FDCommandUpdateEntrant: TFDCommand
    CommandText.Strings = (
      'USE [SwimClubMeet];'
      ''
      'DECLARE @MemberID AS Integer;'
      'DECLARE @EntrantID AS Integer;'
      'DECLARE @TTB AS DateTime;'
      'DECLARE @PB AS DateTime;'
      ''
      'SET @MemberID = :MEMBERID;'
      'SET @EntrantID = :ENTRANTID;'
      'SET @TTB = :TTB;'
      'SET @PB = :PB;'
      ''
      'UPDATE [dbo].[Entrant]'
      '   SET [MemberID] = @MemberID'
      '      ,[RaceTime] = NULL'
      '      ,[TimeToBeat] = @TTB'
      '      ,[PersonalBest] = @PB'
      '      ,[IsDisqualified] = 0'
      '      ,[IsScratched] = 0'
      ' WHERE EntrantID = @EntrantID;')
    ParamData = <
      item
        Name = 'MEMBERID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'ENTRANTID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'TTB'
        DataType = ftTime
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'PB'
        DataType = ftTime
        ParamType = ptInput
        Value = Null
      end>
    Left = 152
    Top = 128
  end
end