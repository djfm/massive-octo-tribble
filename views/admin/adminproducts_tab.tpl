<script>
	var is_custom_pack = {$is_custom_pack};
	var admin_url = {$custompacks_admin_url};

	function updateCustomPack()
	{
		if (is_custom_pack)
		{
			$('#custom_pack').click();
			$('#custom_pack_configuration').show();
			$('#not_a_custom_pack').hide();
			updateComponents();
		}
		else
		{
			$('#custom_pack_configuration').hide();
			$('#not_a_custom_pack').show();
		}
	};

	$(document).ready(function(){
		function setIsCustomPack(boolValue, cb)
		{
			$.post(admin_url+"&ajax-action=setIsCustomPack", {
				id_product: id_product, 
				is_custom_pack: boolValue
			}, cb);
		};

		/* Add a new product type to the UI in the "Information" tab */
		$('#simple_product').next().after($('<input type="radio" name="type_product" id="custom_pack" value="0"><label class="radioCheck" for="custom_pack">{l s='Custom Pack' mod='custompacks' js=1}</label>'));

		updateCustomPack();

		/* Handle the change of product type */
		$('input:radio[name=type_product]').click(function(){
			if ($(this).attr('id') === 'custom_pack')
			{
				if (is_custom_pack === false)
				{
					setIsCustomPack(true, function(resp){
						if(resp === 'true')
						{
							is_custom_pack = true;
							updateCustomPack();
						}
					});
				}
			}
			else
			{
				if (is_custom_pack === true)
				{
					setIsCustomPack(false, function(resp){
						if(resp === 'true')
						{
							is_custom_pack = false;
							updateCustomPack();
						}
					});
				}
			}
		});
	});

	function showOptGroupForm()
	{
		$('#new_optgroup_button').hide();
		$('#new_optgroup_form').show(); 
		event.preventDefault();
		return false;
	};

	function addOptGroup()
	{
		var name = $('#new_optgroup_name').val();

		if(name != '')
		{
			$.post(admin_url+"&ajax-action=addOptGroup", {
					id_product: id_product, 
					name: name
				}, 
				function(resp){
					resp = JSON.parse(resp);
					if(resp.success)
					{
						$('#new_optgroup_button').show();
						$('#new_optgroup_form').hide(); 
						$('#new_optgroup_error').html('');
						updateComponents();
					}
					else
					{
						$('#new_optgroup_error').html(resp.message);
					}
				});
		}
		else
		{
			$('#new_optgroup_error').html('{l s='Please name your group of options.' mod='custompacks' js=1}');
		}

		event.preventDefault();
		return false;
	};

	function updateComponents()
	{	
		$.get(admin_url+"&ajax-action=getComponents", {
				id_product: id_product
			},
			function(resp){
				resp = JSON.parse(resp);
				if(resp.success)
				{
					$('#components').html('');
					for(var c in resp.components)
					{
						$('#components').append(optGroupView(resp.components[c]));
					}
				}
			}
		);
	};

	function optGroupView(group)
	{
		var f = $('<fieldset data-optgroup="'+group.optgroup+'" class="optgroup">');
		f.append('<legend>'+group.optgroup+'</legend>');
		f.append(
			$('<div>')
			.append('<label>{l s='Search products'}</label><input type="text" onkeyup="findProducts(this)"></input>')
			.append($('<div class="products-found"></div>'))
			.append('<p class="light-error"></p>')
		);

		var products = $('<div class="group-products">');

		for(var i in group.products)
		{
			var div = $('<div class="group-product">');
			var button = $('<button>{l s='Remove' mod='custompacks' js=1}</button>');
			button.click((function(i){ return function(){
				$.post(admin_url+'&ajax-action=removeProduct', {
					id_product: id_product,
					optgroup: group.optgroup,
					id_product_to_remove: i
				}, function(resp){
					resp = JSON.parse(resp);
					updateComponents();
				});
				event.preventDefault();
				return false;
			}})(i));
			div.append(button);
			div.append("<span>"+group.products[i].name+"</span>");
			products.append(div);
		}

		f.append(products);

		return f;
	};

	function findProducts(e)
	{
		$.get(admin_url+'&ajax-action=findProducts', {
			query: $(e).val()
		}, function(resp){
			resp = JSON.parse(resp);
			var list = $(e).closest('fieldset.optgroup').find('div.products-found');
			list.html('');
			for(var i in resp)
			{
				list.append(productResultView(resp[i]));
			}
		});
	};

	function productResultView(data)
	{
		var div = $('<div>');
		var button = $('<button>{l s='Add' mod='custompacks'}</button>');
		button.click(function(){
			var fieldset = button.closest('fieldset.optgroup');
			var optgroup = fieldset.attr('data-optgroup');
			$.post(admin_url+"&ajax-action=addProduct", {
				optgroup: optgroup,
				id_product: id_product,
				id_product_to_add: data.id_product
			}, function(resp){
				resp = JSON.parse(resp);
				if(resp === true)
				{
					updateComponents();
				}
				else
				{
					fieldset.find('.light-error').html(resp);
				}
			});
			event.preventDefault();
			return false;
		});
		div.append(button);
		div.append($('<span class="product-result">').html(data.name));
		return div;
	};

</script>

<style>
	{$custompacks_css}
</style>

<div id="not_a_custom_pack">
	{l s='This product is not a custom pack, change the product type in the "Information" tab to access this tab.' mod='custompacks'}
</div>

<div id="custom_pack_configuration">
	<div>
		{l s='Configure you custom pack' mod='custompacks'}
	</div>
	<button id="new_optgroup_button" onclick="showOptGroupForm()">{l s='Add a group of options' mod='custompacks'}</button>
	<div id="new_optgroup_form" style="display:none">
		<label for="new_optgroup_name">{l s='Name' mod='custompacks'}</label>
		<input id="new_optgroup_name" type="text"></input>
		<button onclick='javascript:addOptGroup()'>{l s='Add' mod='custompacks'}</button>
		<div id="new_optgroup_error" class="light-error"></div>
	</div>
	<div id="components">
		
	</div>
</div>