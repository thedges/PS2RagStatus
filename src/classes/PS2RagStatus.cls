public with sharing class PS2RagStatus {
    public PS2RagStatus() {

    }

    @AuraEnabled
    public static void checkDMOs()
    {
        ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
        input.sql = 'SELECT "FilePath__c" FROM "RagFileUDMO__dlm" LIMIT 1';

        ConnectApi.CdpQueryOutputV2 output = ConnectApi.CdpQuery.queryAnsiSqlV2(input);

        input = new ConnectApi.CdpQueryInput();
        input.sql = 'SELECT "FilePath__c" FROM "AiGroundingFileRefCustom__dlm" LIMIT 1';

        output = ConnectApi.CdpQuery.queryAnsiSqlV2(input);
    }

    @AuraEnabled
    public static String getDataLibraries()
    {
        List<ComboItem> cilist = new List<ComboItem>();

        ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
        input.sql = 'SELECT DISTINCT "GroundingSourceId__c" AS "Data Library ID" FROM "AiGroundingFileRefCustom__dlm"';

        ConnectApi.CdpQueryOutputV2 output = ConnectApi.CdpQuery.queryAnsiSqlV2(input);
        for (ConnectApi.CdpQueryV2Row row : output.data){
            ComboItem ci = new ComboItem();
            ci.label = (String)row.rowData[0];
            ci.value = (String)row.rowData[0];
            cilist.add(ci);
        }

        return JSON.serialize(cilist);
    }

    @AuraEnabled
    public static String getFileCounts(String dataLibraryId, String searchIndexAPIName)
    {
        List<FileDetails> fdlist = new List<FileDetails>();

        ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
        input.sql = 'SELECT agf."Name__c" AS LibraryFile,\n' +
                    '       COALESCE(rf.FileCount, 0) AS FileCount,\n' +
                    '       COALESCE(rf.TotalSizeKB, 0) AS TotalSizeKB,\n' +
                    '       COALESCE(rf.ChunkCount, 0) AS ChunkCount,\n' +
                    '       COALESCE(rf.IndexCount, 0) AS IndexCount\n' +
                    ' FROM "AiGroundingFileRefCustom__dlm" agf\n' +
                    'LEFT JOIN (\n' +
                    '   SELECT rf_counts."FilePath__c",\n' +
                    '          rf_counts.FileCount,\n' +
                    '          rf_counts.TotalSizeKB,\n' +
                    '          COUNT(rsi.RecordId__c) AS ChunkCount,\n' +
                    '          COUNT(rid.RecordId__c) AS IndexCount\n' +
                    '     FROM\n' +
                    '     (\n' +
                    '        SELECT "FilePath__c", \n' +
                    '               COUNT(*) AS FileCount,  -- Count FilePath__c before joins\n' +
                    '               ROUND(SUM("Size__c") / 1024.0, 2) AS TotalSizeKB \n' +
                    '          FROM "RagFileUDMO__dlm"\n' +
                    '         GROUP BY "FilePath__c"\n' +
                    '     ) rf_counts\n' +
                    '     LEFT JOIN "RagFileUDMO__dlm" rf ON rf_counts."FilePath__c" = rf."FilePath__c"\n' +
                    '     LEFT JOIN "' + searchIndexAPIName + '_chunk__dlm" rsi ON rf."FilePath__c" = rsi.SourceRecordId__c\n' +
                    '     LEFT JOIN "' + searchIndexAPIName + '_index__dlm" rid ON rsi.RecordId__c = rid.SourceRecordId__c\n' +
                    '     GROUP BY rf_counts."FilePath__c", rf_counts.FileCount, rf_counts.TotalSizeKB \n' +
                    ') rf ON agf."FilePath__c" = rf."FilePath__c"\n' +
                    ' WHERE agf."GroundingSourceId__c" = \'' + dataLibraryId + '\'\n' +
                    ' ORDER BY 1';

        ConnectApi.CdpQueryOutputV2 output = ConnectApi.CdpQuery.queryAnsiSqlV2(input);
        for (ConnectApi.CdpQueryV2Row row : output.data){
            FileDetails fd = new FileDetails();
            fd.name = (String)row.rowData[0];
            fd.count = (Long)row.rowData[1];
            fd.size = (Double)row.rowData[2];
            fd.chunkCount = (Long)row.rowData[3];
            fd.indexCount = (Long)row.rowData[4];
            fdlist.add(fd);
        }

        return JSON.serialize(fdlist);
    }

    // PS2RagStatus.test();
    public static void test() {
      String tmpStr = getDataLibraries();
       System.debug(tmpStr);

       //tmpStr = getFileCounts('1JaHr000000oLlNKAU');
       System.debug(tmpStr);
    }

    public class ComboItem {
        public String label;
        public String value;
    }

    public class FileDetails {
        public String name;
        public Long count;
        public Double size;
        public Long chunkCount;
        public Long indexCount;
    }
}