object TarDataModule: TTarDataModule
  OldCreateOrder = False
  Height = 150
  HorizontalOffset = 86
  VerticalOffset = 85
  Width = 150
  object DSAllDatabases: TDataSource
    DataSet = QAllDatabases
    Top = 8
  end
  object MainConnection: TPQConnection
    Connected = True
    LoginPrompt = False
    DatabaseName = 'www'
    KeepConnection = True
    Password = 'postgres'
    Transaction = MainTransaction
    UserName = 'postgres'
    HostName = 'localhost'
    Left = 1248
    Top = 37
  end
  object MainTransaction: TSQLTransaction
    Active = True
    Database = MainConnection
    Left = 1248
    Top = 95
  end
  object QAllDatabases: TSQLQuery
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
    Left = 1248
    Top = 124
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
      'create table org_group('
      '  id serial primary key,'
      '  name varchar'
      ');'
      'create table organization('
      '  id serial primary key,'
      '  name varchar'
      ');'
      ''
      'create table person('
      '  id serial primary key,'
      '  familyname varchar,'
      '  firstname varchar,'
      '  middlename varchar'
      ');'
      ''
      'create table doljnost('
      '  id serial primary key,'
      '  name varchar'
      ');'
      ''
      'create table predmet('
      '  id serial primary key,'
      '  name varchar'
      ');'
      ''
      'create table stavka('
      '  id serial primary key,'
      '  name varchar'
      ');'
      'create table nadbavka('
      '  id serial primary key,'
      '  name varchar'
      ');'
      'create table doplata('
      '  id serial primary key,'
      '  name varchar'
      ');'
      ''
    )
    Terminator = ';'
    UseDefines = False
    Left = 29
    Top = 8
  end
  object DSSprPersons: TDataSource
    DataSet = QSprPersons
    Left = 58
    Top = 8
  end
  object QSprPersons: TSQLQuery
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
    Active = True
    Database = MainConnection
    Transaction = MainTransaction
    SQL.Strings = (
      'select * from person;'
    )
    Left = 87
    Top = 8
  end
end
