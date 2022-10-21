using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.IO.Compression;
using System;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

public static class CabinetDBAdmin
{
    private static void emptyDir(string path)
    {
        if (!Directory.Exists(path))
        {
            return;
        }

        DirectoryInfo di = new DirectoryInfo(path);
        foreach (FileInfo file in di.GetFiles())
        {
            file.Delete();
        }

        foreach (DirectoryInfo dir in di.GetDirectories())
        {
            dir.Delete(true);
        }

        return;
    }

    // create a new cabinet from an unnasigned rom and return its name (not used)
    public static string CreateGenericForUnnasignedRom(string rom, string path = "", string cabinetModel = "galaga",
        bool invertx = false, bool inverty = false, string orientation = "vertical")
    {
        path = String.IsNullOrEmpty(path) ? ConfigManager.CabinetsDB : path;

        string cabName = Path.GetFileNameWithoutExtension(rom);
        string pathDest = Path.Combine(path, cabName); //$"{path}/{cabName}/";

        if (!Directory.Exists(pathDest))
            Directory.CreateDirectory(pathDest);

        var cbinfo = new CabinetInformation
        {
            rom = Path.GetFileName(rom),
            name = cabName,
            style = cabinetModel,
            timetoload = 8,
            year = 1980,
            material = "black",
            crt = new()
            {
                type = "19i",
                orientation = orientation,
                screen = new()
                {
                    damage = "low",
                    invertx = invertx,
                    inverty = inverty,
                }
            },
            Parts = new()
            {
                new()
                {
                    name = "marquee",
                    type = "marquee",
                    art = new CabinetInformation.Art()
                    {
                        file = "marquee.png"
                    },
                    color = new() { r = 238, g = 232, b = 176, intensity = -2 }
                }
            }
        };
        var serializer = new SerializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .Build();
        var yaml = serializer.Serialize(cbinfo);
        File.WriteAllText($"{pathDest}/description.yaml", yaml);

        return cabName;
    }

    private static void DecompressFile(string path, string destPath)
    {
        ConfigManager.WriteConsole($"[DecompressFile] from {path} to {destPath}");
        // using FileStream compressedFileStream = File.Open(path, FileMode.Open);
        // using FileStream outputFileStream = File.Create(destPath);
        // using var decompressor = new GZipStream(compressedFileStream, CompressionMode.Decompress);
        // decompressor.CopyTo(outputFileStream);
        ZipFile.ExtractToDirectory(path, destPath);
    }

    public static string GetNameFromPath(string path)
    {
        return Path.GetFileNameWithoutExtension(path);
    }

    //load the contents of the zip file and move them to the database cabinet directory. Deletes the original zip file.
    public static void loadCabinetFromZip(string path)
    {
        string cabZipFileName = GetNameFromPath(path);
        string pathDest = $"{ConfigManager.CabinetsDB}/{cabZipFileName}/";
        if (!Directory.Exists(pathDest))
            Directory.CreateDirectory(pathDest);
        else
            emptyDir(pathDest);

        // Object.ZipUtility.UncompressFromZip(path, null, $"{ConfigManager.CabinetsDB}/{cabZipFileName}");
        DecompressFile(path, $"{ConfigManager.CabinetsDB}/{cabZipFileName}/");
        File.Delete(path);
    }

    // check for new zip files, decompress and storage them into the cabinet DB
    public static void loadCabinets()
    {
        string[] files = Directory.GetFiles(ConfigManager.Cabinets, "*.zip");
        foreach (string file in files)
        {
            if (File.Exists(file) && !file.EndsWith("/test.zip"))
            {
                try
                {
                    loadCabinetFromZip(file);
                }
                catch (System.Exception e)
                {
                    ConfigManager.WriteConsole($"ERROR decompressing Cabinet {file} Exception: {e}");
                }
            }
        }

        return;
    }
}
