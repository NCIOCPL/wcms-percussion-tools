using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;

using OfficeOpenXml;

namespace ExtractHelpText
{
    class Program
    {
        const String CONTENT_TYPE_FILESPEC = "psx_ce*";
        const String OUTPUT_FILE = "types.xlsx";

        private void Doit(String objectStorePath)
        {
            DirectoryInfo di = new DirectoryInfo(objectStorePath);
            if (!di.Exists)
                throw new ArgumentException(string.Format("Path '{0}' does not exist.", objectStorePath));

            FileInfo outfileInfo = new FileInfo(Path.Combine(Environment.CurrentDirectory, OUTPUT_FILE));
            if (outfileInfo.Exists)
            {
                outfileInfo.Delete();
                outfileInfo = new FileInfo(Path.Combine(Environment.CurrentDirectory, OUTPUT_FILE));
            }

            using (ExcelPackage outputFile = new ExcelPackage(outfileInfo))
            {
                FileInfo[] filelist = di.GetFiles(CONTENT_TYPE_FILESPEC);
                XmlDocument doc = new XmlDocument();

                XmlAttributeCollection attributes;
                String contentTypeID;
                String contentTypeName;

                foreach (FileInfo file in filelist)
                {
                    Console.WriteLine(file.Name);
                    doc.Load(file.OpenText());

                    XmlNode editorInfo = doc.SelectSingleNode("/PSXApplication/PSXContentEditor");
                    attributes = editorInfo.Attributes;

                    contentTypeID = attributes["contentType"].Value;

                    // Create the new tab
                    ExcelWorksheet currentTab;
                    XmlNode nameNode = editorInfo.SelectSingleNode("PSXDataSet/name/text()");
                    contentTypeName = nameNode.Value;
                    currentTab = outputFile.Workbook.Worksheets.Add(contentTypeName);
                    currentTab.Column(1).Width = 20.0;
                    currentTab.Cells[1, 1].Value = "Content Type ID:";
                    currentTab.Cells[1, 2].Value = contentTypeID;
                    currentTab.Cells[2, 1].Value = "Source:";
                    currentTab.Cells[2, 2].Value = file.Name;

                    // Find the list of fields
                    XmlNodeList displayInfo = editorInfo.SelectNodes("//PSXUIDefinition/PSXDisplayMapper/PSXDisplayMapping");
                    int offset = 4;
                    foreach (XmlNode displayMap in displayInfo)
                    {
                        // Field name
                        XmlNode fieldNameNode = displayMap.SelectSingleNode("FieldRef/text()");
                        currentTab.Cells[offset, 1].Value = fieldNameNode.Value;

                        // Help text
                        XmlNode helptext = displayMap.SelectSingleNode("PSXUISet/PSXControlRef/PSXParam[@name='helpText']/DataLocator/PSXTextLiteral/text/text()");
                        if (helptext != null)
                        {
                            currentTab.Cells[offset, 2].Value = helptext.Value;
                        }

                        ++offset;
                    }
                }

                outputFile.Save();
            }
        }

        static void Main(string[] args)
        {
            if (args.Length == 1)
            {
                Program migrate = new Program();
                migrate.Doit(@"C:\ObjectStore");
            }
            else
            {
                Console.WriteLine("Syntax: ExtractHelpText <path-to-objectStore-folder>");
            }
        }
    }
}
