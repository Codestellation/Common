﻿using System.IO;

namespace Codestellation.Common.Streams
{
    public static class StreamExtensions
    {
        public static void ExportTo(this Stream self, string fileName, bool overwrite = false)
        {
            var fileMode = overwrite ? FileMode.Create : FileMode.CreateNew;
            using (var filestream = File.Open(fileName, fileMode, FileAccess.Write))
            {
                self.CopyTo(filestream);
            }
        }

        public static string ExportToTempFile(this Stream self)
        {
            var fileName = Path.GetTempFileName();
            self.ExportTo(fileName, true);
            return fileName;
        }
    }
}