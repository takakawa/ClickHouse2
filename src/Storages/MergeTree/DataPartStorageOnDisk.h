#pragma once
#include <Storages/MergeTree/IDataPartStorage.h>
#include <memory>
#include <string>

namespace DB
{

class IVolume;
using VolumePtr = std::shared_ptr<IVolume>;


class DataPartStorageOnDisk final : public IDataPartStorage
{
public:
    DataPartStorageOnDisk(VolumePtr volume_, std::string root_path_, std::string part_dir_);

    std::unique_ptr<ReadBufferFromFileBase> readFile(
        const std::string & path,
        const ReadSettings & settings,
        std::optional<size_t> read_hint,
        std::optional<size_t> file_size) const override;

    bool exists(const std::string & path) const override;
    bool exists() const override;

    Poco::Timestamp getLastModified() const override;

    size_t getFileSize(const std::string & path) const override;

    DiskDirectoryIteratorPtr iterate() const override;
    DiskDirectoryIteratorPtr iterateDirectory(const std::string & path) const override;

    std::string getFullPath() const override;
    std::string getFullRelativePath() const override;

    UInt64 calculateTotalSizeOnDisk() const override;

    bool isStoredOnRemoteDisk() const override;
    bool supportZeroCopyReplication() const override;

    void writeChecksums(MergeTreeDataPartChecksums & checksums) const override;
    void writeColumns(NamesAndTypesList & columns) const override;
    void writeDeleteOnDestroyMarker(Poco::Logger * log) const override;

    bool shallParticipateInMerges(const IStoragePolicy &) const override;

    void rename(const String & new_relative_path, Poco::Logger * log, bool remove_new_dir_if_exists, bool fsync) override;

    std::string getName() const override;

    DataPartStoragePtr getProjection(const std::string & name) const override;

private:
    VolumePtr volume;
    std::string root_path;
    std::string part_dir;
};

class DataPartStorageBuilderOnDisk final : public IDataPartStorageBuilder
{
    DataPartStorageBuilderOnDisk(VolumePtr volume_, std::string root_path_, std::string part_dir_);

    bool exists() const override;
    bool exists(const std::string & path) const override;

    void createDirectories() override;

    std::string getFullPath() const override;

    std::unique_ptr<ReadBufferFromFileBase> readFile(
        const std::string & path,
        const ReadSettings & settings,
        std::optional<size_t> read_hint,
        std::optional<size_t> file_size) const override;

    std::unique_ptr<WriteBufferFromFileBase> writeFile(
        const String & path,
        size_t buf_size) override;

    void removeFile(const String & path) override;
    void removeRecursive() override;

    ReservationPtr reserve(UInt64 bytes) override;

    DataPartStorageBuilderPtr getProjection(const std::string & name) const override;

private:
    VolumePtr volume;
    std::string root_path;
    std::string part_dir;
};

}
