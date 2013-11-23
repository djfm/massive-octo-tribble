{foreach from=$components item=optgroup}
	<div>
		<h4>{$optgroup.optgroup}</h4>
		{if $optgroup.opttype == 'unique'}
			{foreach from=$optgroup.products item=product key=id_product}
				<input type="checkbox" id="{$optgroup.optgroup}_{$id_product}" name="optgroup_{$optgroup.optgroup}">
				<label for="{$optgroup.optgroup}_{$id_product}">{$product.name}</label><BR/>
			{/foreach}
		{/if}
	</div>
{/foreach}