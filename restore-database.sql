DECLARE @backupPath varchar(1000)='/var/opt/sqlserver/databasebackup.bak'
DECLARE @dataFileTable TABLE ([LogicalName] varchar(128),[PhysicalName] varchar(128), [Type] varchar(128), [FileGroupName] varchar(128), [Size] varchar(128), 
	[MaxSize] varchar(128), [FileId] varchar(128), [CreateLSN] varchar(128), [DropLSN] varchar(128), [UniqueId] varchar(128), [ReadOnlyLSN] varchar(128), [ReadWriteLSN] varchar(128), 
    [BackupSizeInBytes] varchar(128), [SourceBlockSize] varchar(128), [FileGroupId] varchar(128), [LogGroupGUID] varchar(128), [DifferentialBaseLSN] varchar(128), 
	[DifferentialBaseGUID] varchar(128), [IsReadOnly] varchar(128), [IsPresent] varchar(128), [TDEThumbprint] varchar(128), [SnapshotUrl] varchar(128)
)

DECLARE @dataLogicalNameData varchar(128)
INSERT @dataFileTable
EXEC('
RESTORE FILELISTONLY 
   FROM DISK=''' +@backupPath+ '''
   ')
   SET @dataLogicalNameData=(SELECT LogicalName FROM @dataFileTable WHERE Type='D')

DECLARE @logFileTable TABLE ([LogicalName] varchar(128),[PhysicalName] varchar(128), [Type] varchar(128), [FileGroupName] varchar(128), [Size] varchar(128), 
	[MaxSize] varchar(128), [FileId] varchar(128), [CreateLSN] varchar(128), [DropLSN] varchar(128), [UniqueId] varchar(128), [ReadOnlyLSN] varchar(128), [ReadWriteLSN] varchar(128), 
    [BackupSizeInBytes] varchar(128), [SourceBlockSize] varchar(128), [FileGroupId] varchar(128), [LogGroupGUID] varchar(128), [DifferentialBaseLSN] varchar(128), 
	[DifferentialBaseGUID] varchar(128), [IsReadOnly] varchar(128), [IsPresent] varchar(128), [TDEThumbprint] varchar(128), [SnapshotUrl] varchar(128)
)

DECLARE @logLogicalNameData varchar(128)
INSERT @logFileTable 
EXEC('
RESTORE FILELISTONLY 
   FROM DISK=''' +@backupPath+ '''
   ')
   SET @logLogicalNameData = (SELECT LogicalName FROM @logFileTable WHERE Type='L')

DECLARE @databaseNameTable TABLE ([BackupName] varchar(128), [BackupDescription] varchar(128), [BackupType] varchar(128), [ExpirationDate] varchar(128), [Compressed] varchar(128), [Position] varchar(128),
	[DeviceType] varchar(128), [UserName] varchar(128), [ServerName] varchar(128), [DatabaseName] varchar(128), [DatabaseVersion] varchar(128), [DatabaseCreationDate] varchar(128), [BackupSize] varchar(128),
	[FirstLSN] varchar(128), [LastLSN] varchar(128), [CheckPointLSN] varchar(128), [DatabaseBackupLSN] varchar(128), [BackupStartDate] varchar(128), [BackupFinishDate] varchar(128), SortOrder varchar(128),
	[CodePage] varchar(128), [UnicodeLocaleId] varchar(128), [UnicodeComparisonStyle] varchar(128), [CompatibilityLevel] varchar(128), [SoftwareVendorId] varchar(128), [SoftwareVersionMajor] varchar(128),
	[SoftwareVersionMinor] varchar(128), [SoftwareVersionBuild] varchar(128), [MachineName] varchar(128), [Flags] varchar(128), [BindingID] varchar(128), [RecoveryForkID] varchar(128),[Collation] varchar(128), 
	[FamilyGUID] varchar(128), [HasBulkLoggedData] varchar(128), [IsSnapshot] varchar(128), [IsReadOnly] varchar(128), [IsSingleUser] varchar(128), [HasBackupChecksums] varchar(128), [IsDamaged]varchar(128),
	[BeginsLogChain] varchar(128), [HasIncompleteMetaData] varchar(128), [IsForceOffline] varchar(128), [IsCopyOnly] varchar(128), [FirstRecoveryForkID] varchar(128), [ForkPointLSN] varchar(128), 
	[RecoveryModel] varchar(128),[DifferentialBaseLSN] varchar(128), [DifferentialBaseGUID] varchar(128), [BackupTypeDecription] varchar(128), [BackupSetGUID] varchar(128), [CompressedBackupSize] varchar(128), 
	[Containment] varchar(128), [KeyAlgorithm] varchar(128), [EncryptorThumbprint] varchar(128), [EncryptorType] varchar(128)
)
	
DECLARE @databaseNameData varchar(128)
INSERT @databaseNameTable 
EXEC('
RESTORE HEADERONLY 
   FROM DISK=''' +@backupPath+ '''
   ')
   SET @databaseNameData = (SELECT DatabaseName FROM @databaseNameTable);

-- DECLARE @changeDatabase varchar(100) = 'USE ' + @databaseNameData + ';'
--EXEC(@changeDatabase)

DECLARE @dataDirectory varchar(200) = N'/var/opt/sqlserver/' + @databaseNameData + '.mdf';
DECLARE @logDirectory varchar(200) = N'/var/opt/sqlserver/' + @databaseNameData + '_log.ldf';

DECLARE @restoreDatabase varchar(500) = 'RESTORE DATABASE ' + '[' + @databaseNameData + ']' +
' FROM DISK = ''' + @backupPath + '''  
WITH FILE = 1,  
MOVE ''' + @dataLogicalNameData + '''
 TO ''' + @dataDirectory + ''',  
MOVE ''' + @logLogicalNameData + '''
 TO ''' + @logDirectory + ''',  
NOUNLOAD,  REPLACE,  STATS = 5;'

USE Master;
EXEC(@restoreDatabase);