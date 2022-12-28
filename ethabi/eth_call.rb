require 'ethlite'

require_relative 'encode'



## construct a json-rpc call
def eth_call( rpc,
              contract_address,
              data )

  method =  'eth_call'
  params =  [{ to:   contract_address,
               data: data},
            'latest'
            ]

  response = rpc.request( method, params )

  puts "response:"
  pp response

  response
end


def keccak256( bin )
  Digest::KeccakLite.new( 256 ).digest( bin )
end

def sig( bin )
  keccak256( bin )[0,4]
end


def decode_string( bin )

  pos_bin = bin[0,32]   ## first word (32 bytes) holds start position of type
  pos = pos_bin.hexdigest.to_i( 16 )

  if pos != 32
    putx "!! ERROR - decoding - expected start pos 32; got: #{pos}"
    exit 1
  end

  ## convert big endian integer encoded byte string to integer
  size_bin = bin[32,32]
  size_hex = size_bin.hexdigest
  size =  size_hex.to_i(16)
  puts "  string of size: #{size} (0x#{size_hex})"
  puts "    bytes available in buffer: #{bin.size - 64}"

   ## note. use size - no need to remove right zero padding??
  str = bin[64,size]
  str.force_encoding( Encoding::UTF_8 )
  str   ## todo/check:   change encoding to utf-8 or such (from binary - why? why not?)
end





ETH_NODE  = JsonRpc.new( ENV['INFURA_URI'] )

## contract address - let's try moonbirds
moonbirds = '0x23581767a106ae21c074b2276d25e5c3e136a68b'
marcs     = '0xe9b91d537c3aa5a3fa87275fbd2e4feaaed69bd0'

# contract_address =   marcs
contract_address = moonbirds

sig = 'tokenURI(uint256)'     # returns (string)

puts "sighash:"
pp sighash = sig( sig ).hexdigest


token_ids = [0,1]
token_ids.each do |token_id|
  ## binary encode method arg(ument)s
  puts "args:"
  pp args_encoded = encode_uint256( token_id ).hexdigest

  data = '0x' + sighash + args_encoded
  puts "data:"
  pp data

  puts "==> calling tokenURI(#{token_id})..."
  tokenURI = eth_call( ETH_NODE, contract_address, data )
  puts "   ...returns:"
  ## pp tokenURI
  str = decode_string( tokenURI.hex_to_bin )
  puts str.encoding
  pp str
end


puts "bye"

__END__

==> moonbirds
string of size: 58 (0x000000000000000000000000000000000000000000000000000000000000003a)
    bytes available in buffer: 64

==> marcs
string of size: 14665 (0x0000000000000000000000000000000000000000000000000000000000003949)
bytes available in buffer: 14688

string of size: 13665 (0x0000000000000000000000000000000000000000000000000000000000003561)
bytes available in buffer: 13696



==> moonbirds
token no.0:
0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003a68747470733a2f2f6c6976652d2d2d6d657461646174612d35636f767071696a61612d75632e612e72756e2e6170702f6d657461646174612f30000000000000
"https://live---metadata-5covpqijaa-uc.a.run.app/metadata/0"


token no.1:
0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003a68747470733a2f2f6c6976652d2d2d6d657461646174612d35636f767071696a61612d75632e612e72756e2e6170702f6d657461646174612f31000000000000

"https://live---metadata-5covpqijaa-uc.a.run.app/metadata/1"


==> marcs

token no.1:
0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000003561646174613a6170706c69636174696f6e2f6a736f6e3b6261736536342c65794a755957316c496a6f6951334a356348527649453168636d4e7a49434d78496977695a47567a59334a7063485270623234694f694a4249474e766247786c5933527062323467623259674e57736751334a35634852765457467959334d675a6e567362486b675432347451326868615734674c5342545a576c366157356e4948526f5a5342745a57316c637942765a694277636d396b64574e30615739754969776963335a6e58326c745957646c58325268644745694f694a6b595852684f6d6c745957646c4c334e325a79743462577737596d467a5a5459304c464249546a4a616555497a595664534d4746454d476c4e56456c3354554e4a5a324648566e42614d6d677755464e4a654531715158644a61554979595664574d3146744f54525155306c33535552425a3031555358644e513046345457704264306c70516a4a615745703659566335645642545358684d616b6c705355686f64474a484e587051553070765a456853643039704f485a6b4d32517a5447356a656b78744f586c6165546835545552426430777a546a4a6165556c6e597a4e534e574a4856546c4a6255706f57544a30626d4e744f54466962564630575449356332497a53545a6b5345706f596d354f64316c59536d7869626c453357573147616d45795a486c694d315a31576b4d7863474a58526d3561564841785932313362317048526a425a56484277596c6447626c70544f58646962574d3357573147656c70555754424d523278585557733555325236516b78534d6d523255565647516c46564e56525756326847566c646b516c4656526b4e614d455a4355565647576c4577526c705256555a43556b646b613256715454425256555a435556564f57564672624668585254464355565647656c5a46526b4a52565868475a444257516d4a59516a4e5856555a43555656475332457965455a56566c705455316473624530774e55355656565a435556564763564a464d55355265546778545774575247527465464e5256454633596d3547656b30794d4456525747524355565647516c4656526b4a54626d74345558706b646c4a46654774615347784556577873516c4656526b4a52566b3557566d733555314e36566b52585657784b55464e7263325259536e4e4c52314a6f5a4564464e6d46584d5768614d6c563259306331626b3879536d686a4d6c5579546b4e3463465a72536c4256626d4e33557a426b626d4977526b4a5256555a505654465762314a57566d355256555a435557316b516c4656526b4a585655354356315647516c4656556d356153473936546b5647516c4656526b52585255704b566a466f546c4656526b4a6a4d564a435556564754564a595a455a52567a46335a444673516c4656526b4a546258527a556c5a4756315672624842615645355056465a47526c4656526b4a6861314a4f5646564e646b3555536b5a524d31707a56577446643031484e58686a656b3530543156474d314656526b4a5256555a43555656774e55315654544e694d464a4e576b64534e564578536c705256555a435556564756465a57576c425661334d7855544673536c4e554d48424d53465a35596b4e6f61316c59556d6850625778305756646b6245777a516e5661656e52705756684f6245357155584e68566c70445644464b4d303146644568614d6a6c4355565647516c5273546c5a6852565a57576a4247516c4656536d355256555a4355565a735246465762454a5256555a46576a4a534e6b3136556b4a5256555a435554466f51314e575a466c5556555a435556684f56564656526b4a555256597a556c564764474e495a46705256555a4355565677636d4a46566c4a576245704b59566456656c52724d564a5356555a4355566477525652564d55524d656c5635556c564f4d6d4a47536b4a4e52454a315931684e656d4a5562454a6b4d455a4355565647516c4656526b746c56455a45546a493552565248556d746c5655355456315647516c4656526b4a564d565a585644464b54453556546c70545657733553314e344d574e7464323961523059775756527763474a58526d3561557a6c33596d316a4e316c74526e706156466b7754456473563146724f564e6b656b4a4d556a4a6b646c4656526b4a5256545655566c646f526c5a585a454a5256555a44576a4247516c4656526c70524d455a6155565647516c4a485a47746c616b307755565647516c4656546c6c526132785956305578516c4656526e705752555a4355565634526d5177566b4a695745497a56315647516c4656526b74684d6e684756565a6155314e586247784e4d44564f56565657516c4656526e46535254464f55586b344d553172566b526b625868545556524264324a75526e704e4d6a41315556686b516c4656526b4a5256555a4355323572654646365a485a5352586872576b68735246567362454a5256555a4355565a4f566c5a724f564e54656c5a4556315673536c425461334e6b5745707a533064536147524852545a68567a466f576a4a56646d4e484e5735504d6b706f597a4a564d6b354465484257613070515657356a64314d775a4735694d455a435556564754315578566d3953566c5a7555565647516c46745a454a5256555a435631564f516c6456526b4a5256564a75576b6876656b3546526b4a5256555a455630564b536c59786145355256555a43597a4653516c4656526b315357475247555663786432517862454a5256555a4356305a5763314a57526c645661327877566a46424e4578354f44524d4d4559315455564b526b3145526b395452475258576e7047536c4e73536b524e526d7777556a423456316f7a526b646861305a53596a4e7363465a46614770536258424859306842636d4e36556b6c68613170555a577447516d4e57526b56564d553079556a4a7356564a72526e6c5553455a58596c5634635646565558644f52327843596a4a57566d46595a4735534d3342435658704a4d6d4e485a4746534d55354755336b354e6b78354f545a4d4d55705259565653614646584e55705261305a4759337061526d565963445a4e61334d7757577447516c4656526b4a5356336848566b643056475257526e52524d4531775445685765574a446147745a57464a6f5432317364466c585a47784d4d304a31576e703061566c59546d784f616c467a59565a6151315178536a4e4e52585249576a4935516c4656526b4a556245355759555657566c6f77526b4a525655707555565647516c465762455252566d78435556564752566f79556a5a4e656c4a4355565647516c457861454e54566d525a56465647516c4659546c565256555a43564556574d314a56526e526a5347526155565647516c46564f48646952565a53566d784b536d46575a464650517a683254304d35516d5655516b4e53564546345647746e4d315a745a4746536258424356566335556c6c57624442545747684b54316430574655774f574661565842595957705a4e4539484e57686b56574e33576c687757474658634564694d32686f5646566b65564675526b4a576131497a56565673516b39495a4670544d486868566c5a47625752495a454a5256555a4355565a4f566c5a724f564e54656c5a4556315673536c425461334e6b5745707a533064536147524852545a68567a466f576a4a56646d4e484e5735504d6b706f597a4a564d6b354465484257613070515657356a64314d775a4735694d455a435556564754315578566d3953566c5a7555565647516c46745a454a5256555a435631564f516c6456526b4a5256564a75576b6876656b3546526b4a5256555a455630564b536c59786145355256555a43597a4653516c4656526b315357475247555663786432517862454a5256555a435532313063314a57526c645661327877576c524f54315257526b5a5256555a4359577453546c525654585a4f5645704755544e61633156725258644e527a56345933704f64453956526a4e5256555a4355565647516c46566344564e5655307a596a425354567048556a56524d55706155565647516c4656526c5257566c70515657747a4d56457862457054564442775445685765574a446147745a57464a6f5432317364466c585a47784d4d304a31576e703061566c59546d784f616c467a59565a6151315178536a4e4e52585249576a4935516c4656526b4a556245355759555657566c6f77526b4a525655707555565647516c465762455252566d78435556564752566f79556a5a4e656c4a4355565647516c457861454e54566d525a56465647516c4659546c565256555a43564556574d314a56526e526a5347526155565647516c465663484a6952565a53566d784b536d465856587055617a4653556c5647516c465863455655565446455448705665564a56546a4a69526b70435455524364574e5954587069564778435a444247516c4656526b4a5256555a4c5a565247524534794f55565552314a725a56564f55316456526b4a5256555a435654465756315178536b784f56553561553156724f5574546544466a62586476576b64474d466c556348426956305a75576c4d3564324a74597a645a62555a36576c525a4d45784862466452617a6c545a487043544649795a485a5256555a435556553156465a5861455a57563252435556564751316f77526b4a5256555a6155544247576c4656526b4a53523252725a57704e4d464656526b4a525655355a55577473574664464d554a5256555a36566b5647516c465665455a6b4d465a43596c68434d316456526b4a5256555a4c59544a34526c5657576c4e545632787354544131546c5656566b4a5256555a78556b5578546c46354f44464e61315a455a4731345531465551586469626b5a36545449774e5646595a454a5256555a4355565647516c4e7561336852656d5232556b563461317049624552566247784355565647516c4657546c5a57617a6c545533705752466456624570515532747a5a46684b63307448556d686b523055325956637861466f7956585a6a527a5675547a4a4b61474d7956544a4f51336877566d744b55465675593364544d475275596a4247516c4656526b39564d565a76556c5a57626c4656526b4a526257524355565647516c6456546b4a5856555a4355565653626c70496233704f52555a435556564752466446536b70574d57684f55565647516d4d78556b4a5256555a4e556c686b526c46584d58646b4d57784355565647516c4e7464484e53566b5a585657747363467055546b3955566b5a4755565647516d4672556b355556553132546c524b526c457a576e4e56613056335455633165474e36546e52505655597a55565647516c4656526b4a52565841315456564e4d324977556b3161523149315554464b576c4656526b4a5256555a55566c5a6155465672637a46524d57784b5531517763457849566e6c695132687257566853614539746248525a5632527354444e436456703664476c5a57453573546d705263324657576b4e554d556f7a5455563053466f794f554a5256555a435647784f566d4646566c5a614d455a435556564b626c4656526b4a52566d784555565a73516c4656526b56614d6c493254587053516c4656526b4a524d57684455315a6b57565256526b4a525745355655565647516c5246566a4e5356555a305930686b576c4656526b4a52566d7857596b5657556c5a73536b706856315635565441354d303572526b35525747684655305a6f576c70726546465a65546c5755573177646c4672526e4a5561315a34576a42536257457a566b6c574d6a5631557a4e6f4e564e56546c6c4f4d484258553052424d6c497963334a4e56553558566b525356315177536e4a5257457048545870734d314656536d706c523368485457706f51316471546d356a5631704e56544a6155475672556e4e6a524752495554413154324e57526c4e4e62565a30576c5a5762465a7555586c6a5232684c55315673536c4a56566b5a6b626d684d597a4247555578365a454e535230353256556331516b3173526b4a5256555a435557747755315a55566b5a6a6258524c576a4a6b626c42554d48424d53465a35596b4e6f61316c59556d6850625778305756646b6245777a516e5661656e52705756684f6245357155584e68566c70445644464b4d303146644568614d6a6c4355565647516c5273546c5a6852565a57576a4247516c4656536d355256555a4355565a735246465762454a5256555a46576a4a534e6b3136556b4a5256555a435554466f51314e575a466c5556555a435556684f56564656526b4a555256597a556c564764474e495a46705256555a4355566861636d4a46566c4a576245704b59565a6b54315258536e644e656b7031546b566b53466f7762465a575747685a56444e4b656b7377556e704f565456685930524754565a745a476c6962465a595a4870614d566c724e484a53616d684f56305a5a654749796244526852577836576b686b51316f78624568685233687154544a4a4d6c5245556e42534d32524e597a424b6331517962484257613156795631564756466f774e5770524d6c704d546d746f516c5a5663334a534d467075576d317752324e46526e4e52566d4d7a5a45524b4e474645536b314e56336845545556574e474d7961336856566c5a58566d313463464636556a466c52327778556a42344e565a57536a42535655705456305a4a64324675526c6854566c497a5a44466b646c4a585a47746856466f7859315a5757475656546e526a6254677a5630567352325177576b6c505657527a557a4a4b523146745a47354f567a6c3159544e73533039585a45646c5647684c556b647364453546566b39694d315a56566a4a4757566f796345646a52476871556b564b52553146526c564f565868775655565756315a57566b6853567a56755654427765465579556d35614d446c6f5930564f516c463656586c4e56576852566d3153636c5a584e554a5256555a435556564b5331567356544653574570795532316b626c70364d446c4c564852705756644f636c6f7a536e5a6b567a56725446684b62474e48566d686b52484231596e6b7865567059516d785a5746453357573147616d45795a486c694d315a31576b4d78656d46596347785062553532596d3553614746584e44645a62555a7159544a6b6557497a566e5661517a4633596a4e4f6347524862485a69616e4271576c63314d46705953546468567a466f576a4a5664474e74566e566152315a3559566331626b39704d544e6156307079595668526447497a516a4268567a46775a57315664466b794f58566b5345706f597a4e524e3078584d58704d563278315a45645765574e484f584e5a57464a77596a493064474a584f57746156484231576c644765567059546a424d567a56735956646b62316c744f586c504d6d78305756646b62457859536d786962564a73593231736456703662335269567a6b325446644f65574659546e644d56315a72576a4a57656b38796248525a563252735446684b62474a74556d786a62577831576e7077643246596147786952305977576c64524e306c714e44684d4d303479576e6f3050534973496d6c745957646c58325268644745694f694a6b595852684f6d6c745957646c4c334e325a79743462577737596d467a5a5459304c464249546a4a616555497a595664534d4746454d476c4e56454633536c4e4a5a324648566e42614d6d677755464e4a654531455157784a61554979595664574d3146744f54525155306c33535552425a3031555358644e513046345457704264306c70516a4a615745703659566335645642545358684d616b6c705355686f64474a484e587051553070765a456853643039704f485a6b4d32517a5447356a656b78744f586c6165546835545552426430777a546a4a6165556b725545647364466c585a47784a53475277576b6853623142545358684e616b463353576c43623170586247356853464535535770466555314551576c4a52326835576c645a4f556c74556d686b523055325956637861466f7956585a6a4d317075537a4e6f64474a4564476c5a57453573546d7052633156466145394e624841315557704f614659785358645a565646335956557856564e595a4535524d4778755756566b56324e4762336c6852454a52565442734e46525863454a6b4d4778775557704b6146597857587056567a4131546b5a4356464e595a45705352555a7556465a53536d51774d5552525747684f595774474d314e5862454e4e6248425a5532357761465a3662444656526b354b5a55563463564e5862457054523267775757746a4d575673516c525462546c7255305a4b4d315179617a526b62564636576b524f54574a74546a5a55527a41315a565a774e553949624535535255597a5645524f5430317363445654563252715454464a4d566c725a465a50565778305532316f576b3175556e565a4d6a41315456644b64465659556c704e616d78365757704f536b3574556b6c5462576870596d73314d31645761457469523070315656526b576d4a56576e465a564570725a56644a656c5a75566d4652656b5a335757786b52324a736346566a52455a71596c686b646c64725a45644e526d78565930684361565977576e5658624530315a444a4b64466c365a46706956566f3256327853576b314665456869526d5253595870735646704963454e55526b6c35576b6861556c5a56576b4e56566c5578566b5a6157474646576c64574d6c4a4456565a57523145786233645361307053566c566159565655516b645862455a57556d744b55314979556e4a615633424f54555a47566c4a72536c4a575654566156566430633164475a455a4e56557053566c56614e6c5a72566b645262455a575a55566161303147576b4e5a624768445454466b566c4a72536c4a575656704d5756524b4e464a73566c645862453555566a4a34633152555154465562465a57566d744b556c5a56576e685661315634564778474e553945526b35684d567046576b63784e465578526c565257475270596d74614e6c52555358644f566b5a5a576b564b556c5a56576b4e56566c5a485557784f6457457a61464a6c62564979565774574e47457863456c6952564a57596b643451315657566b645262455a585647786156324636624652564d334258556b5a6b566d4a46634646564d6e5236576b5a6f53324d776445685662576872556a42564d6c6c5759336868526d3935566c6861616c4a36566e5655656b704c5955644e65565a55536b39524d326833566d313053315647566e565a4d3252555455645364566c71516b645262455a57556d7335566b3157576e5a5662467058596d7847566c4a72536c4a6956314a4456565a57523146735a465a5561307059566c566151315657566c4e696248424a596a4e7754314a56576b4e56566c5a48556b5a6b526c4e726346644e5632685056565a57523146745458685661307053566c5661546c56736147745362455a595456686b6130315865454e56566c5a485557784f64475249546c4e5761317059566c643063324e4763465655617a6c56566d746152315657566b645262555a795657733156565a564d544a5562464a4c556d7846656c6475546c5a684d46597a5646566a4d575648546a5a55626c4a51566c565a656c5657566b645262455a57556d744b556c5a5951544655566c5a4f54544a4a643156724d5746534d556b785656524753316473526c5a5361307053566c566156565a73576d4656526c5a7959337047556b3158654574564d5646335930563453565a7562476c524d6d687956315a6f553246464f58526953464a61566a4a5363315245546b4e6b566e41325a456473576c64464e584e5562584253597a4a4756316472546c564e56573936564656574d464e4762336c5056557053566c566151315a486545395762555a47566d786159553146576b4e56566c5a4c596d7847566c4a72536c4a576258684656565a6163314673526c5a5361315a685457784a4d6c525963464e5262455a57556d744b556b3158614552564d56707256315a53566c4a72536c4a585254565756565a5752314673556b5a57616b3554566c56614d466b776147745862455a57556d744b556c5a59516e6c5a61315a585657786163314e72634768574d565932566b647a65465673536c5a5361307053566a4e43526c5a475658685352586732566c687355315a564e486c5a6131704c5557737852564675566d70585254453257577853633146745558645361307053566c566151315657566b64544d6c5a56556d74535430317162455a575257525459544a57566c5273546c68575656704456565a575231467356586857624752565456567754565273566b395862453557595870735446557a5a33685a4d6a457a596a467753464a71516c705753454a335757786b52324a736346525057475270596c644e4d3164584d55646c6248425656315243545649796546685656334d3156544a534e6c467265464e4e6256497956565a5752314673526c5a4f566c4a58566a4a6f52315a735a47745262455a57556d744f59553146576b4e56566c5a485632784664314a7363464a57565670445657746b61324579566e465556454a53566c566151315657566b3958566b5a79596b5a6f57464a55526b4e56566c5a485a577861526c4a72536c4a5757476848576b524356314674536c6c52616b3559566c566151315657566b64544d6b56355a555661566c5a73634652564d57527a596b5577643035564e565a57566c704456565a5752324e57536b5a4e565456535a56526e654652586446645352314a305a555a4f556c5a46526a4e5a625456485a57737765553145566c4a5852314a4456565a5752314673526c5a5361307055596d31304e4656596347746b624570475a55643059564e48654556575633687a55577847566c4a72536c4a57617a5658566d317a4e565578546a5a5761314a59566c643453315647546e4a6a4d6c4a5a5532354f54464978536d396152575247546d3147574531586147464e624659795754426a4d574a724f486c54625768715457785665565272546a526a526c707955327843566d4a74546a4e56656b4a72596d314a64314a72536c4a5756567051566c524756324978536c645762545653566c5661513156584d57745262455a57556d744b57465a564e554e574d565a4855577847566c56744e574654527a6b325647745752314673526c5a5361314a59556c567753315a71526d395562455a57556d744b616b3157536b4e56566c5a4856465a4b57567046576c4a57656b597a576b524763314673526c5a5361307059556d7861656c5673576b64574d565a79596b6843563031565254425553477330546b563364314a71566b3553565842485646565352315178546b5661526d52685a577461533155796545745352544648596b52435530314961466858616b3548556a4a47636c4a73536d6c4e4d6e6833566d745762324673536e526a525752715530564765566b7a63464e5456305a795632785362474577576b4e5a4d567048556c5a5665465255536c4e4e625868575657313052325657556b6c5362475270566c686f65465657566c4a6b4d445649596b564b61553173576c645a566d6872596d784a656d4e46536c5a6c613274355754426b61316c5753586855613170555a5652724d6c5249617a564f613364345532784761465a57536d3956566d4d7855327847636c4a72576d706c62484248576c5a6f643035724d584a6a656b4a615954426151315657566b6452624570595a55566b5631497a556c5661526c70485a455a4664315259516b3154526c6f315757744f6232457862466c5662576851596c64344d4664575a477469525864365557355759575675556e4258566d6850596b553163565659546d685762484245566b5247533030774d555a6b525768685457707351315657566b645262464a7a5647786161464a57576c6458616b4a4855577847566c4e744e564a575656704456565a6163314a47526c646952557053566c5661526c6471536c4e4f617a45325657744b556c5a56576b4e5656455a765554464f56317047624656575656704456565a6f54315a57526c5a5361307056556c5a5a656c5673566b646b5230354a576b5a77556c5a56576b4e56566c55305a444a4b526c5a73536c64695258424c57565a61613156564f555250534670515558707351317057556b4e524d5570565556686f56574579593370576254467257565a4b64474e46536c5a57656d785456315a6163303147546c6c6852584251566a4e5357565a555154565a566e425759305a6f61474673617a42554d474d7859556453566c6b7a5a47465853454a5a57565a6b643149795358706852326856566c64534e5656584e556452624670795657704f566c5a5865454e554d4768725632784e64325648526c645761317030576b566f61314673526c5a5361307053566d733156315a74637a56564d553432566d745357465a5865457456526b3579597a4a5357564e75546b78534d557076576b566b526b3574526c684e56326868545778574d6c6b77597a4669617a68355532316f616b317356586c556130343059305a61636c4e73516c5a696255347a5658704361324a745358645361307053566c566155465a55526c64694d557058566d3031556c5a56576b4e56567a467255577847566c4a72536c685756545644566a465752314673526c5a5662545668553063354e6c5272566b645262455a57556d745357464a5663457457616b5a7656477847566c4a72536d704e566b704456565a5752315257536c6c6152567053566e70474d317045526e4e5262455a57556d744b56474a59556e705662467048566a4657636d4a49516d465752545651566b5a6152314a73526c5a536130706f5954464b54315a47566b356b617a565655327461556b307863487057563352475a444178534535596147706c617a55775644465752303078526c5a5361307053566c566151315657566e644f565446575646524f61553147536b355861325254546c5a4665464e7363464a575656704456565a5752315a47576c645862454a5759544e4e65465655526e4e54624535565455684354564e47576a565a613035765954467357565674614642695633677756315a6b61324a4664337052626c5a685a5735536346645761453969525456785656684f61465a736345525752455a4c54544178526d52466147464e616d784456565a5752314673556e4e556246706f556c5a6156316471516b645262455a5755323031556c5a56576b4e56566c707a556b5a4756324a46536c4a57565670475632704b553035724d545a5661307053566c566151315655526d39524d553558576b5a7356565a56576b4e56566d6850566c5a47566c4a72536c5653566c6c365657785752325248546b6c61526e4253566c566151315657566e646a62557047566d784b56324a466345745a566d52575a577853636b3157536c4e575656704456565a6b64314a57556c5a4e56564a4e5a5778574e565673566b394e625570485532744b546c4a46536a465a4d57684f5a57314b56574a46536d744e5256704456565a5752314673526c5a5361335273566b56615256527153545653566c4a495657313062465a564e5652574d565a4855577847566c4a72536c5a4e566c7059566b5247533152464e565a5562484255566c647a4e564d78546a524e563035305a4449355956497757586458566c4a335930644b57464a744e574656656d777a57573078616b347862485253626e4268566b5a72643152465a484e574d555a7954315a4f61325672536b3156616b70725a477847566c4a72536c4a5756465a56566d786b62314a73576c686152557053566c566152466471516b645262455a57556d7877556b3146576d4656566c5a485557784b5346704864477868617a423356565a5752314673526c5a556247785359544a34575659775658685262455a57556d357756314a56576b4e56566c5930556d315264315a72536d6c5852556c36566a465752314673526c5a536133526f5457356f52315a57576d46564d553559596b6434546b3145566b3957566c5a5855577847566c4a75526c4e5356455a50565668724e4531564d584a5761314a72596c686f56465657556b4a6b4d6b7031556d3577546b317151544656566d687255577847566c4a72536c4a575656704456544931636d5647526a5a6153467054556c686f636c647261484e53526c5a7a596b564b556c5a56576b4e56566c7050566d7861636b3957546c526c62467046566a465763314e73516c52684d30357256305677656c4d775a464e6852314a49556c526161465a36526d3958616b70575a47314f534535584e56424e613342765758704b566b31724e55526c53454a585954427755565a584e57706b4d553133576b633161553146576b4e56566c5a485644465665465a744f564e576246703156565a5752314673526e526152557053566c566151315978566b395262475257556d744b556c5a57536e5658613268325a577331526c4a72536c4a5756567046566a425753314e735758686852545653566c566151316c36526c4e5262455a57556d737855316448556b6456566d4e345a444a5265474a46536c4a5756567044565449784d474d78536c64536247525759544a3464316473556b39554d564a58556d7461556c5a56576b4e5a5633525456477853566c5259576b3957525842485656524f59574d78566e4a535747524f556e70574e466b7a6345396b52546c57556d704f556c5a56576b4e56566c5a4855577847566d4e45566b355756544236575770435531525763456856616c5a535456567759565657566b645262455a57556d785356315a73634646575633523654565a4665474a466346525752454a335645566f56325658536b52685233526156305a4b623151794d584e6b526d7859576b643454553077536a4658626e417759565a73575652746545396862455a3657565a615956457855586854616b354f556c6853535664715354565262455a57556d744b56574a464e56645a56565a58566d787664314a72536c4a575658423156565a5752314673526c646952564a53566d313451315657566b6453566d393556577061546d5673536b4e56566c5a485557784665474646546c525762564a61566b5a5752314673526c6c5562465a53566c566151315a46566c644e4d557057556d3553616c4e48556d4656566c5a485557784756324a47576d6c53566c7054566d313453314e74526c68575747785754555272656c52746445645562455a5a5955565756464a74614746586258513056565a734e553957576c4a69574549795656643052324e73556e4a57626d686854555a4b64466c55546c6454566c6c35546c6857564530795a7a46564d565a505631553064324e475a465253525556355657704b656d4e724d565a5562475258556b5a4b57465a45516b746a62455a5a5532746b546d567464337056566c5a4c59573157534756465a45356862576845566a4a7754324a74546c6858617a4657545778775556705864464e6a4d6b3546576b566f556b3145566c425a4d5670485654417864465a75556d46576246707a566d3031556d5658546b686852585255566c643453315673566c645362564a3159555634616b3146576c4a55534842725554464b53465275576c5a53656c5a445646643452314673526c5a536130705359544e4356465a73556c6453625535305a45563059553174556e5656526c46335930563453565a7562476c524d6d687956315a6f553246464f58526953464a61566a4a5363315245546b4e6b566e41325a456473576c64464e584e5562584253597a4a4756316472546c564e56573936564656574d464e4762336c5056557053566c566151315a486545395762555a47566d786159553146576b4e56566c5a4c596d7847566c4a72536c4a576258684656565a6163314673526c5a5361315a685457784a4d6c525963464e5262455a57556d744b556b3158614552564d56707256315a53566c4a72536c4a585254565756565a5752314673556b5a57616b3554566c56614d466b776147745862455a57556d744b556c644763486c5a61315a585657786163314e726347685762564a51566b5a6b533251774d545a54626c5a50556c645353566471516e4e576246705a59555a735655307763445a54656b4a545a577331566b3558526d70535256704f566d307861324658536e4e57624768725a57787665466458637a426a624570785955553157464a736244525a616b707a546b6447526d4a496347465452314a455632704763314e48526b686c5233424f5457747265565a46556c4e6a526b6c36576b5578616b3146634870575245707a59305a61636c5a59536c685756567056563270424d57467352586c586133685059544a6f51315a73566e706a62456c335632303159574a59516b685a4d465a48597a464756316c36546d74535257387757565653533152564d56686c52564a4f556c5a5a4d466c36536e4a6c526c5a58566d786b56324a5961486456574842545456645753474a45526c4e4e53476378566d786153303147536c5a5462453559556d74734d316c584e556458526b35585657704f61303158556a4a566247527259544a4756566471526d70576246705a576c5a5754325248546e525052453559556c643453467045516d465456546c57576b684f5645317263456856567a4672596d733157453959566d684e4d6e684d5644466b61314979566c566852585254556a4a344d465272566c64554d6b6c36566d785756303172576c7058616b7033556a4a4f5257464863464e53565842475646565752315a564e565a6c53454a57556c5a6157465a73576c6454526b7059546c6331566b3149516a525756457054596d787664303958614770535654564456566877566d56564d565a68526b5a58596c5a4b65565a73597a465262455a57556d744b556c5a56634578575633685754565a4b57564e75536c526956314a3156323576643039566446566b52327861566a413165566471546b746b62564a59546c64305456644663484e5a4d4752585955645352574e49566d6c6c564559315632786f51324a4762466c5656475261596c566163566c55536d746c56306c36566d355759564636526a5a5a566d6833596b553564465275576d6c696245707657565a6a4d453478624852536258426f545731534e566c71546c646b566e42455456686b615530774e5864615257527a5a47314b63574e4863474657656c56335632786f536b3479526c684e56326868545778574d466b794d56646b566e4249566d357361465a36566e56554d6d74345454467757464e75536d6858526b59775757704f51303148526c684e57454a73596c5a574d4664555354566b56314a4a5532316f616b307852544e55526d4e345a57743457474a49566d74534d566f315754426a4e574d7862466c56626b4a70545770534d466c73597a56684d5842565930685759565977576a5658624768505455563457453558654768574d6c4a32563163774e5756564f486c6953464a61566a4a5363315247614574695230703056573134616d4a5865444658626e42325a45644b57453955576b31574d44553157565a6f543251776546685762585268545778614e6c5236536e4e6b526d7859576b64345456644663484e5a62544654596b644f64474a49566d466c626b497a57565a6f62324a48536b6853616b4a68566a46464d314e58627a4250525864365647704b5957567155546c4a616a513454444a7364466c585a477851616e6432597a4e61626c426e505430694c434a686448527961574a316447567a496a706265794a30636d4670644639306558426c496a6f694d53387849697769646d4673645755694f694a50636d6c6e6157356862434a394c48736964484a686158526664486c775a534936496b31766458526f49697769646d4673645755694f694a4e59584a6a496e307365794a30636d4670644639306558426c496a6f6952586c6c63794973496e5a686248566c496a6f695457467959794a394c48736964484a686158526664486c775a534936496b787063484d694c434a32595778315a534936496b3168636d4d6966537837496e527959576c3058335235634755694f694a4759574e70595777675347467063694973496e5a686248566c496a6f69526e4a76626e5167516d5668636d51675247467961794a394c48736964484a686158526664486c775a534936496b686c595751694c434a32595778315a534936496b686c595752695957356b496e307365794a30636d4670644639306558426c496a6f69546d566a61794973496e5a686248566c496a6f695457467959794a394c48736964484a686158526664486c775a534936496b3576633255694c434a32595778315a534936496b3168636d4d6966537837496e527959576c3058335235634755694f694a46595849694c434a32595778315a534936496b3168636d4d6966537837496e527959576c3058335235634755694f694a46625739306157397549697769646d4673645755694f694a4e59584a6a496e307365794a30636d4670644639306558426c496a6f69526d466a5a534973496e5a686248566c496a6f6953473979626e4d6966537837496e527959576c3058335235634755694f694a4e59584a6a49465235634755694c434a32595778315a534936496b3168636d4d674d694a395858303d00000000000000000000000000000000000000000000000000000000000000



