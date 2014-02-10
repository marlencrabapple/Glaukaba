var ext = sitevars.noext == 1 ? "" : ".html";
var _catalog = {'threads':[]};
var direction = 1;
_catalog.threads = catalog.threads.slice(0);
init();

function init() {
	$('.cat-item-container').remove();
	set_hover_events();
	
	$(catalog.threads).each(function(index) {
		if((this.image === undefined) || (this.image == sitevars.domain + "/img/nofile.png")) {
			this.isdeleted = 1;
			this.image = sitevars.domain + "/img/nofile.png";
			this.catitemw = 100;
			this.catitemh = 25;
			this.noplace = 25;
		}
		else {
			this.catitemw = this.tn_w > 125 ? this.tn_w * .6 : this.tn_w;
			this.catitemh = this.tn_h > 125 ? this.tn_h * .6 : this.tn_h;
			this.noplace = this.tn_h > 125 ? this.tn_h * .6 : this.tn_h;
		}
		
		this.link = sitevars.boardpath + "res/" + this.no + ext;
		this.showtext = 1;
		
		$('#catalog').append($('#catalog-template').jqote(this));
	});
}

function set_hover_events() {
	$('#catalog').on('mouseenter','.cat-item',function() {
		$(this).children('.cat-item-inner').css('display','block');
	});
	
	$('#catalog').on('mouseout','.cat-item-inner',function() {
		$('.cat-item-inner').css('display','none');
	});
}

function change_order(order) {
	direction = order;
	catalog.threads.reverse();
	init();
}

function sort_catalog(sortby) {
	if(sortby == "replies") {
		catalog.threads.sort(function(a,b) {
			if(direction == 1) {
				return b.postcount - a.postcount;
			}
			else {
				return a.postcount - b.postcount;
			}
		});
	}
	else if(sortby == "images") {
		catalog.threads.sort(function(a,b) {
			if(direction == 1) {
				return b.imagecount - a.imagecount;
			}
			else {
				return a.imagecount - b.imagecount;
			}
		});
	}
	else if(sortby == "creation") {
		catalog.threads.sort(function(a,b) {
			if(direction == 1) {
				return b.no - a.no;
			}
			else {
				return a.no - b.no;
			}
		});
	}
	else {
		if(direction == 1) {
			catalog.threads = _catalog.threads.slice();
			search_catalog(document.getElementById('cat-input').value);
			return;
		}
		else {
			catalog.threads = _catalog.threads.reverse().slice();
			search_catalog(document.getElementById('cat-input').value);
			return;
		}
	}
	
	init();
}

function search_catalog(qstr) {
	catalog.threads = [];
	$(_catalog.threads).each(function(index) {
		this.com = this.com === undefined ? "" : this.com;
		this.sub = this.sub === undefined ? "" : this.sub;
		this.filename = this.filename === undefined ? "" : this.filename;
		this.name = this.name === undefined ? "" : this.name;
		this.trip = this.trip === undefined ? "" : this.trip;
		
		if(qstr === null) {
			catalog.threads = _catalog.threads.slice(0);
			change_order(order);
			return;
		}
		else if((this.com.toLowerCase().indexOf(qstr) != -1) || (this.sub.toLowerCase().indexOf(qstr) != -1) || (this.filename.toLowerCase().indexOf(qstr) != -1) || (this.name.toLowerCase().indexOf(qstr) != -1) || (this.trip.toLowerCase().indexOf(qstr) != -1)) {
			catalog.threads.push(this);
		}
	});
	
	init();
}
