{foreach from=$components item=optgroup}
	<div>
		<h4>{$optgroup.optgroup}</h4>
		
		<form id="cp-customization">	
			{foreach from=$optgroup.products item=product key=idProduct}
				<input type="{if $optgroup.opttype == 'unique'}radio{else}checkbox{/if}" id="c_{$optgroup.id_optgroup}_{$idProduct}" name="cog[{$optgroup.id_optgroup}][]" value="{$idProduct}">
				<label for="c_{$optgroup.id_optgroup}_{$idProduct}">{$product.name}</label><BR/>
			{/foreach}
		</form>
	</div>
{/foreach}

<script>
	$('form#cp-customization').change(function(){
		var query = $('form#cp-customization').serialize();
		$.post('{$customize_url}&ajax-action=updateCustomization&id_product={$id_product}&'+query, function(resp){

		});
	});
</script>