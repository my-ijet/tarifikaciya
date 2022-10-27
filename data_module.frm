object TarDataModule: TTarDataModule
  OldCreateOrder = False
  Height = 150
  HorizontalOffset = 86
  VerticalOffset = 85
  Width = 150
  object MainConnection: TPQConnection
    Connected = False
    LoginPrompt = False
    DatabaseName = 'www'
    KeepConnection = True
    Password = 'postgres'
    Transaction = MainTransaction
    UserName = 'postgres'
    HostName = 'localhost'
    VerboseErrors = False
    Left = 1248
    Top = 37
  end
  object MainTransaction: TSQLTransaction
    Active = False
    Database = MainConnection
    Left = 1248
    Top = 95
  end
  object QAllDatabases: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'databases'
        DataType = ftString
        Precision = -1
        Size = 64
      end>
    Database = MainConnection
    Transaction = MainTransaction
    ReadOnly = True
    SQL.Strings = (
      'SELECT datname as databases'
      'FROM pg_database'
      'WHERE datistemplate = false'
      'and datname <> ''postgres'';'
      ''
    )
    InsertSQL.Strings = (
      ''
    )
    RefreshSQL.Strings = (
      ''
    )
    Options = [sqoKeepOpenOnCommit]
    Left = 1248
    Top = 124
  end
  object DSAllDatabases: TDataSource
    DataSet = QAllDatabases
    Top = 8
  end
  object SQLCreateTables: TSQLScript
    DataBase = MainConnection
    Transaction = MainTransaction
    AutoCommit = True
    Directives.Strings = (
      'SET TERM'
      'COMMIT WORK'
      'COMMIT RETAIN'
      'COMMIT'
      '#IFDEF'
      '#IFNDEF'
      '#ELSE'
      '#ENDIF'
      '#DEFINE'
      '#UNDEF'
      '#UNDEFINE'
    )
    Script.Strings = (
      ''
      '-- SU'
      'create table organization('
      '  id serial primary key,'
      '  short_name varchar,'
      '  full_name varchar,'
      '  archived boolean not null default false,'
      '  pg int2,'
      '  gr int2'
      ');'
      '-- SPRPG'
      'create table org_group('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false'
      ');'
      '-- SPRFIO'
      'create table person('
      '  id serial primary key,'
      '  familyname varchar,'
      '  firstname varchar,'
      '  middlename varchar,'
      '  archived boolean not null default false'
      ');'
      '-- SPROBR'
      'create table obrazovanie('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false'
      ');'
      '-- SPRGR'
      'create table personal_group('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false'
      ');'
      '-- SPRDL'
      'create table doljnost('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false,'
      '  kolvo int2,'
      '  por int2,'
      '  pk int2,'
      '  gopl int2'
      ');'
      '-- SPRKAT'
      'create table kategory('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false'
      ');'
      '-- SPRPREDM'
      'create table predmet('
      '  id serial primary key,'
      '  name varchar,'
      '  clock int2,'
      '  archived boolean not null default false'
      ');'
      '-- STAVKI'
      'create table stavka('
      '  id serial primary key,'
      '  razr int2,'
      '  sumst money,'
      '  archived boolean not null default false'
      ');'
      '-- SPRN'
      'create table nadbavka('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false,'
      '  proc numeric(4,1),'
      '  por int2,'
      '  pr varchar(1)'
      ');'
      '-- SPRDP'
      'create table doplata('
      '  id serial primary key,'
      '  name varchar,'
      '  archived boolean not null default false,'
      '  por int2,'
      '  pk int2,'
      '  pr varchar(1)'
      ');'
      ''
    )
    Terminator = ';'
    UseDefines = False
    Left = 29
    Top = 8
  end
  object DSSpravochniky: TDataSource
    DataSet = QOrganizations
    Left = 58
    Top = 8
  end
  object QOrganizations: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'short_name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'full_name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'archived'
        DataType = ftBoolean
        Precision = -1
      end    
      item
        Name = 'pg'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'gr'
        DataType = ftSmallint
        Precision = -1
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from organization'
      'where archived = :ISARCHIVED;'
    )
    InsertSQL.Strings = (
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftBoolean
        Name = 'ISARCHIVED'
        ParamType = ptInput
        Value = False
      end>
    UpdateMode = upWhereChanged
    Left = 116
    Top = 8
  end
  object QPersons: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'familyname'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'firstname'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'middlename'
        DataType = ftString
        Precision = -1
        Size = 8192
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from person'
      'where archived = :ISARCHIVED;'
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftBoolean
        Name = 'ISARCHIVED'
        ParamType = ptInput
        Value = False
      end>
    UpdateMode = upWhereChanged
    Left = 87
    Top = 8
  end
  object QOrgGroups: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from org_group'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Top = 37
  end
  object QObrazovanie: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from obrazovanie'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 29
    Top = 37
  end
  object QDoljnost: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'kolvo'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'por'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'pk'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'gopl'
        DataType = ftSmallint
        Precision = -1
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from doljnost'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 87
    Top = 37
  end
  object QKategories: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from kategory'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 116
    Top = 37
  end
  object QPredmet: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'clock'
        DataType = ftSmallint
        Precision = -1
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from predmet'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Top = 66
  end
  object QStavka: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'razr'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'sumst'
        DataType = ftCurrency
        Precision = -1
      end    
      item
        Name = 'archived'
        DataType = ftBoolean
        Precision = -1
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from stavka'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 29
    Top = 66
  end
  object QNadbavka: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'proc'
        DataType = ftBCD
        Precision = -1
        Size = 1
      end    
      item
        Name = 'por'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'pr'
        DataType = ftString
        Precision = -1
        Size = 1
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from nadbavka'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 58
    Top = 66
  end
  object QDoplata: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end    
      item
        Name = 'por'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'pk'
        DataType = ftSmallint
        Precision = -1
      end    
      item
        Name = 'pr'
        DataType = ftString
        Precision = -1
        Size = 1
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from doplata'
      'where archived = :ISARCHIVED;'
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 87
    Top = 66
  end
  object QPersonalGroups: TSQLQuery
    PacketRecords = -1
    IndexName = 'DEFAULT_ORDER'
    MaxIndexesCount = 4
    FieldDefs = <    
      item
        Name = 'id'
        DataType = ftInteger
        Precision = -1
      end    
      item
        Name = 'name'
        DataType = ftString
        Precision = -1
        Size = 8192
      end>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from personal_group'
      'where archived = :ISARCHIVED;'
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Params = <    
      item
        DataType = ftUnknown
        Name = 'ISARCHIVED'
        ParamType = ptInput
      end>
    UpdateMode = upWhereChanged
    Left = 58
    Top = 37
  end
  object QAllTarDates: TSQLQuery
    PacketRecords = -1
    FieldDefs = <>
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      ''
    )
    Options = [sqoKeepOpenOnCommit, sqoAutoApplyUpdates, sqoAutoCommit, sqoCancelUpdatesOnRefresh]
    Left = 116
    Top = 66
  end
end
