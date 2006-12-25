class ProfileItem
  def self.exist?(profileId)
      return DataService.doesDataGroupExist?(profileId)
  end
end