xunlei-lixian
=============
迅雷离线下载脚本。

### 声明
迅雷离线下载为会员功能。非会员无法使用。

Quick start
-----------

	python lixian_cli.py login "Your Xunlei account" "Your password"
	python lixian_cli.py login "Your password"
	python lixian_cli.py login

	python lixian_cli.py config username "Your Xunlei account"
	python lixian_cli.py config password "Your password"

	python lixian_cli.py list
	python lixian_cli.py list --completed
	python lixian_cli.py list --completed --name --original-url --download-url --no-status --no-id
	python lixian_cli.py list --deleted
	python lixian_cli.py list --expired
	python lixian_cli.py list id1 id2
	python lixian_cli.py list zip rar
	python lixian_cli.py list 2012.04.04 2012.04.05

	python lixian_cli.py download task-id
	python lixian_cli.py download ed2k-url
	python lixian_cli.py download --tool=wget ed2k-url
	python lixian_cli.py download --tool=asyn ed2k-url
	python lixian_cli.py download ed2k-url --output "file to save"
	python lixian_cli.py download id1 id2 id3
	python lixian_cli.py download url1 url2 url3
	python lixian_cli.py download --input download-urls-file
	python lixian_cli.py download --input download-urls-file --delete
	python lixian_cli.py download --input download-urls-file --output-dir root-dir-to-save-files
	python lixian_cli.py download bt://torrent-info-hash
	python lixian_cli.py download 1.torrent
	python lixian_cli.py download torrent-info-hash
	python lixian_cli.py download --bt http://xxx/xxx.torrent
	python lixian_cli.py download bt-task-id/file-id
	python lixian_cli.py download --all
	python lixian_cli.py download mkv
	python lixian_cli.py download 2012.04.04
	python lixian_cli.py download 0 1 2
	python lixian_cli.py download 0-2

	python lixian_cli.py add url
	python lixian_cli.py add 1.torrent
	python lixian_cli.py add torrent-info-hash
	python lixian_cli.py add --bt http://xxx/xxx.torrent

	python lixian_cli.py delete task-id
	python lixian_cli.py delete url
	python lixian_cli.py delete file-name-on-cloud-to-delete

	python lixian_cli.py pause id

	python lixian_cli.py restart id

	python lixian_cli.py rename id name

	python lixian_cli.py logout

安装指南
--------

1. 安装git（非github用户应该只需要执行第一步Download and Install Git）

      http://help.github.com/set-up-git-redirect

2. 下载代码（Windows用户请在git-bash里执行）

        git clone git://github.com/iambus/xunlei-lixian.git

3. 安装Python 2.x（请下载最新的2.7版本。不支持Python 3.x。）

      http://www.python.org/getit/

4. 在命令行里运行

        python lixian_cli.py

注：不方便安装git的用户可以选择跳过前两步，在github网页上下载最新的源代码包（选择"Download as zip"或者"Download as tar.gz"）：

https://github.com/iambus/xunlei-lixian/downloads


一些提示
--------

1. 你可以为python lixian_cli.py创建一个别名（比如lx），以减少敲键次数。

      Linux上可以使用：

        ln -s 你的lixian_cli.py路径 ~/bin/lx

      Windows上可以创建一个lx.bat脚本，放在你的PATH中：

        @echo off
        python 完整的lixian_cli.py路径 %*

      注：下文中提到的lx都是指python lixian_cli.py的别名。

2. 你可以使用lx config保存一些配置。见“命令详解”一节。

        lx config delete
        lx config tool asyn
        lx config username your-id
        lx config password your-password

      注：密码保存的时候会加密（hash）

3. 部分命令有短名字。lx d相当于lx download，lx a相当于lx add，lx l相当于lx list，lx x相当于lx list。也可以通过plugin api自己添加alias。

4. 使用lx download下载的文件会自动验证hash。其中ed2k和bt会做完整的hash校验。http下载只做部分校验。

      注：包含多个文件的bt种子，如果没有完整下载所有文件，对于已下载的文件，可能有少量片段无法验证。如果很重视文件的正确性请选择下载bt种子中的所有文件。（目前还没有发现由于软件问题而导致hash验证失败的情况。）

5. 如果觉得大文件的hash速度太慢，可以关掉：

        lx download --no-hash ...

      也可以使用lx config默认关掉它：

        lx config no-hash

6. lx hash命令可以用于手动计算hash。见“其他工具”一节。


命令详解
--------

注：下文中提到的lx都是指python lixian_cli.py的别名。

常用命令：

* lx login
* lx download
* lx list
* lx add
* lx delete
* lx pause
* lx restart
* lx rename
* lx readd
* lx config
* lx info
* lx help

### lx login
登录，获得一个有效session，默认保存路径是~/.xunlei.lixian.cookies。一般来说，除非服务器故障或者执行了lx logout（或者你手动删除了cookies文件），否则session的有效期是一天左右。session过期之后需要手动重新执行login。但如果使用lx config password把密码保存到配置文件里，则会自动重新登录。后文会介绍[lx config](#lx-config)。

lx login接受两个参数，用户名和密码。第二次登录可以只填密码。

    lx login username password
    lx login password

如果不希望明文显示密码，也可以直接运行

    lx login

或者使用-代替密码

    lx login username -

上面的命令会进入交互式不回显的密码输入。

可以用--cookies指定保存的session文件路径。-表示不保存（在login这个例子里，没什么实际意义）。

    lx login username password --cookies some-path
    lx login username password --cookies -

注意，除了lx login外，大多数lx命令，比如lx download，都需要先执行登录。这些命令大多支持--username和--password，以及--cookies参数，根据传递进来的参数，检查用户是否已经登录，如果尚未登录则尝试登录。一般来说不建议在其他命令里使用这些参数（因为麻烦），除非你不希望保存session信息到硬盘。

### lx download
下载。目前支持普通的http下载，ed2k下载，和bt下载。可以使用thunder/flashget/qq旋风的连接（bt任务除外）。在信息足够的情况下（见“一些提示”一节的第3条），下载的文件会自动验证hash，出错了会重新下载（我个人目前还没遇到过下载文件损坏的情况）。见“一些提示”一节的第3条。

    lx download id
    lx download http://somewhere
    lx download ed2k://somefile
    lx download bt://info-hash
    lx download link1 link2 link3 ...
    lx download --all
    lx download keywords
    lx download date

对于bt任务，可以指定本地.torrent文件路径，或者torrent文件的info hash。（很多网站使用info hash来标识一个bt种子文件，这种情况你就不需要下载种子了，lx download可以自动下载种子，不过前提是之前已经有人使用迅雷离线下载过同样的种子。[如后所述](#其他工具)，你也可以使用lx hash --info-hash来手动生成bt种子的info hash。）

    lx download Community.S03E01.720p.HDTV.X264-DIMENSION.torrent
    lx download 61AAA3C6FBB8B71EBE2F5A2A3481296B51D882F6
    lx download bt://61AAA3C6FBB8B71EBE2F5A2A3481296B51D882F6

如果url本身指向了要添加任务的种子文件，需要加上--bt参数告诉lx脚本这是一个种子。

    lx download --bt http://tvu.org.ru/torrent.php?tid=64757

可以把多个连接保存到文件里，使用--input参数批量下载：

    lx download --input links.txt

注意：在断点续传的情况下，如果文件已经存在，并且文件大小相等，并且使用了--continue，重新下载并不只是简单的忽略这个文件，而是先做hash校验，如果校验通过才忽略。如果文件比较多或者比较大，可能比较耗时。建议手动从--input文件里删除已经下载过的链接。也可以使用--mini-hash参数，如下。

如果指定了--mini-hash参数，对于已经下载过的文件，并且文件大小正确（一般意味着这个文件的正确性已经在前一次下载中验证过了），会做一个最简单的校验。对于尚未下载完成的任务，在完成之后还是会做完整的hash。

如果指定了--no-hash参数，永远不会做完整的hash。但还是会做文件大小检验和取样hash（很快）。

可以使用--delete参数在下载完成之后删除任务。

    lx download link --delete

如果一个文件已经存在，使用参数--continue支持断点续传，使用--overwrite覆盖已存在的文件，重新下载。

你可能需要用--tool参数来指定下载工具。默认的下载工具是wget，有些环境的wget是最低功能版本，不支持指定cookie或者断点续传。这种情况可以使用--tool=asyn。这在“支持的下载工具”一节有说明。

    lx download --tool=wget link
    lx download --tool=asyn link

--output和--output-dir分别用来指定保存文件的路径和目录。

如果要下载的文件尚未在离线任务里，会被自动添加。

你也可以使用指定要下载的任务id（lx list命令可以用来查看任务id）：

    lx download task-id

但是要注意，多任务下载的时候，不能混用id和url（以后可能会支持）。

类似任务id，也可以指定任务的序列号。序列号从0开始。可以使用lx list -n查看序列号。如果希望lx list默认显示序列号，可以使用lx config n。若要下载任务列表中的第一个任务：

    lx download 0

要下载前三个任务：

    lx download 0-2

对于bt任务，如果只想下载部分文件，可以在task id后指定文件id：

    lx download bt-task-id/file-id bt-task-id/file-id2

或者：

    lx download bt-task-id/[1,3,5-7]

注：上面的命令下载对应bt任务里文件id为1，3，5，6，7的五个文件。

也可以指定bt子文件的扩展名：

    lx download bt-task-id/.mkv

或者：

    lx download bt-task-id/[.mkv,.mp4]

更多的用法：TODO

可以使用--all参数下载所有的任务（如果已经在参数中指定了要下载的链接或者任务id，--all参数会被忽略）：

    lx download --all

也可以使用一个简单的关键字匹配要下载的文件名：

    lx download mkv

也可以搜索多个关键字（满足其中一个就算匹配）：

    lx download mkv mp4

任务的添加日期也可以作为关键字：

    lx download 2012.04.04
    lx download 2012.04.04 2012.04.05

### lx list
列出已存在的离线任务。默认只会列出任务id，任务名，以及状态。可以使用--original-url和--download-url参数来列出原始链接和下载链接。--completed参数用于忽略未完成任务。

    lx list
    lx list --completed
    lx list --no-status --original-url --download-url

如果要列出bt任务的子文件，可以在任务id后面加上/：

    lx list id/

可以使用--deleted或者--expired参数来列出已删除和已过期的任务。

详细参数可以参考lx help list。

### lx add
添加任务到迅雷离线服务器上。

    lx add url1 url2 url3
    lx add --input links.txt
    lx add --bt torrent-file
    lx add --bt torrent-url
    lx add --bt info-hash

提示：lx download会自动添加任务，而无需执行lx add。

### lx delete
从迅雷离线服务器上删除任务。

    lx delete id1 id2
    lx delete ed2k://...
    lx delete mkv
    lx delete --all mkv
    lx delete --all mkv mp4

### lx pause
暂停任务。

    lx pause id1 id2
    lx pause --all mkv

### lx restart
重新开始任务。

    lx restart id1 id2
    lx restart --all mkv

### lx rename
重命名任务

	lx rename task-id task-name

### lx logout
不想保留session可以使用lx logout退出。一般用不着。

     lx logout
     lx logout --cookies your-cookies-file

### lx readd
重新添加已过期或者已删除的任务。

    lx readd --deleted task-id
    lx readd --expired task-name

提示：可以用lx list --deleted或者lx list --expired列出已删除和过期的任务。

### lx config
保存配置。配置文件的保存路径是~/.xunlei.lixian.config。虽然你可以差不多可以保存任何参数，但是目前只有以下几个参数会真正起作用：

* username
* password
* tool
* continue
* delete
* output-dir
* hash
* mini-hash
* id
* n
* size
* format-size
* colors
* wget-opts（见稍后的说明）
* aria2-opts（见稍后的说明）（见支持的下载工具一节）
* axel-opts（见稍后的说明）
* watch-interval
* log-level
* log-path

（因为只有这几个参数我觉得是比较有用的。如果你觉得其他的参数有用可以发信给我或者直接open一个issue。）

不加参数会打印当前保存的所有配置：

    lx config

可以使用--print打印指定的配置：

	lx config --print password

添加一个新的参数：

    lx config username your-username
    lx config password your-password
    lx config delete
    lx config no-delete

删除一个参数：

    lx config --delete password

注：密码是hash过的，不是明文保存。
注：如果不希望在命令行参数中明文保存密码，可以运行lx config password，或者lx config password -，会进入交互式不回显密码输入（只支持password配置）。

关于wget-opts/aria2-opts/axel-opts，因为这些工具的命令行参数一般都包含-，所以需要用额外的--转义。另外多个命令行参数需要用引号合并到一起：

    lx config -- aria2-opts "-s10 -x10 -c"

### lx info
打印cookies文件里保存的迅雷内部id，包括登录的ID，一个内部使用的ID，以及gdriveid。

关于gdriveid：理论上gdriveid是下载迅雷离线链接需要的唯一cookie，你可以用lx list --download-url获取下载地址，然后用lx info获取gdriveid，然后手动使用其他工具下载，比如wget "--header=Cookie: gdriveid=your-gdriveid" download-url。

-i参数可以只打印登录ID：

    lx info -i

如果想把登录id复制到剪切板：

    lx info -i | clip

### lx help
打印帮助信息。

    lx help
    lx help examples
    lx help readme
    lx help download

支持的下载工具
--------------

* wget：默认下载工具。注意有些Linux发行版（比如某些运行在路由设备上的mini系统）自带的wget可能无法满足功能要求。可以尝试使用其他工具。
* asyn：内置的下载工具。在命令行中加上--tool=asyn可以启用。注意此工具的下载表现一般，在高速下载或者设备性能不太好的情况（比如运行在低端路由上），CPU使用可能稍高。在我的RT-N16上，以250K/s的速度下载，CPU使用大概在10%~20%。
* urllib2：内置下载工具。不支持断点续传错误重连，不建议使用。
* curl：尚未测试。
* aria2：测试通过。注意某些环境里的aria2c需要加上额外的参数才能运行。可以使用lx config进行配置：lx config -- aria2-opts --event-poll=select
* axel: 测试通过。注意官方版本的axel有一个URL重定向长度超过255被截断的bug，需要手动修改源代码编译。见issue #44.
* 其他工具，比如ProZilla，暂时都不支持。有需要请可以我，或者直接提交一个issue。


其他工具
--------

* lx hash可以用于手动计算hash。

        lx hash --ed2k filename
        lx hash --info-hash torrent-file
        lx hash --verify-sha1 filename sha1
        lx hash --verify-bt filename torrent-file

* lixian_batch.py是我自己用的一个简单的“多任务”下载脚本。其实就是多个--input文件，每个文件里定义的链接下载到文件所在的目录里。

        python lixian_batch.py folder1/links.txt folder2/links.txt ...

既知问题
--------

1. --tool=asyn的性能不是很好。见“支持的下载工具”一节里的说明。
2. 有些时候任务添加到服务器上，但是马上刷新拿不到这个数据。这应该是服务器同步的问题。技术上可以自动重刷一遍，但是暂时没有做。用户可以自己重试下。
3. bt下载的校验如果失败，可能需要重新下载所有文件。从技术上来讲这是没有必要的。但是一来重下出错的片段有些繁琐，二来我自己都从来没遇到过bt校验失败需要重下的情况，所以暂时不考虑支持片段修复。更新：bt校验失败不会重下。
4. 有时候因为帐号异常，登录需要验证码。目前还不支持验证码。

以后
----

其实一开始是考虑做一个可以在路由器上运行的网页版离线下载管理器的。但是这个工作量比命令行版的大很多（不是一个数量级的），在资源消耗和出错概率上也大很多，而且可能还要有更多的依赖库，安装起来也不方便。当然主要还是精力和需求的原因。现在的这个命令行本对我来说已经够用了，也挺简单，短期就不考虑增加网页版了。

要说的话
--------

我自己也一直在用这个脚本。基本上不管白天还是黑夜，都在路由器（RT-N16）上挂着NTFS的移动硬盘下载。所以脚本的可用性和稳定性还是不错的。速度基本上是满速，有时候由于服务器原因不稳定，可以断掉重下，兴许就能分配到一个状态比较好的服务器上了。具体的性能表现请参考issue #18.

许可协议
--------

xunlei-lixian使用MIT许可协议。

此文档未完成。
--------------

