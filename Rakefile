require 'hoe'
require './lib/blockchain-lite/version.rb'

Hoe.spec 'blockchain-lite' do

  self.version = BlockchainLite::VERSION

  self.summary = "blockchain-lite - build your own blockchain with crypto hashes -  revolutionize the world with blockchains, blockchains, blockchains one block at a time"
  self.description = summary

  self.urls    = ['https://github.com/openblockchains/blockchain.lite.rb']

  self.author  = 'Gerald Bauer'
  self.email   = 'wwwmake@googlegroups.com'

  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'HISTORY.md'

  self.extra_deps = [
    ['merkletree'],
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
    required_ruby_version: '>= 2.3'
  }

end
