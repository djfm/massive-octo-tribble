<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.2/angular.min.js"></script>
<style>
	{$custompacks_css}
</style>

<script>
	var is_custom_pack = {$is_custom_pack};
	var admin_url = {$custompacks_admin_url};

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
						}
					});
				}
			}
		});

		if(is_custom_pack)
		{
			$('#custom_pack').attr('checked', 'checked');
		}
	});

	var CustomPacks = function ($scope, $http)
	{
		$scope.components = {};
		// Models for the product search boxes queries
		$scope.queries	  = {};
		// Results of searches
		$scope.results    = {};

		$scope.opttypes = {
			unique: 'Unique',
			multiple: 'Multiple'
		};

		$scope.updateComponents = function()
		{	
			$http
			.get(admin_url+"&ajax-action=getComponents&id_product="+id_product)
			.then(function(resp){
				if (resp.data.success)
					$scope.components = resp.data.components;
			});
		};

		$scope.searchProducts = function(query, section)
		{
			$http
			.get(admin_url+'&ajax-action=findProducts&query='+query)
			.then(function(resp){
				$scope.results[section] = resp.data;
			});
		};

		$scope.addProduct = function(id_product_to_add, section)
		{
			$http
			.post(admin_url+"&ajax-action=addProduct", {
				optgroup: section,
				id_product: id_product,
				id_product_to_add: id_product_to_add
			})
			.then(function(resp){
				if(resp.data === 'true')
				{
					$scope.updateComponents();
				}
				else
				{
					console.log(resp.data)
				}
			});
		};

		$scope.removeProduct = function(id_product_to_remove, section)
		{
			$http
			.post(admin_url+'&ajax-action=removeProduct', {
				id_product: id_product,
				optgroup: section,
				id_product_to_remove: id_product_to_remove
			})
			.then(function(resp){
				$scope.updateComponents();
			});
		};

		$scope.addSection = function(name)
		{
			if(name !== undefined && name.trim() !== '')
			{
				$http
				.post(admin_url+"&ajax-action=addOptGroup", {
					id_product: id_product, 
					name: name
				})
				.then(function(resp){
					if(resp.data.success)
					{
						$scope.updateComponents();
					}
					else
					{
						console.log(resp.data.message);
					}
				});
			}
		};

		$scope.removeSection = function(name)
		{
			if(name !== undefined && name.trim() !== '')
			{
				$http
				.post(admin_url+"&ajax-action=removeOptGroup", {
					id_product: id_product, 
					name: name
				})
				.then(function(resp){
					if(resp.data.success)
					{
						$scope.updateComponents();
					}
					else
					{
						console.log(resp.data.message);
					}
				});
			}
		};

		$scope.changeOptType = function(id_optgroup, type)
		{
			$http
			.post(admin_url+"&ajax-action=changeOptType", {
				id_optgroup: id_optgroup,
				opttype: type
			});
		};

		$scope.updateComponents();
	}
</script>

{literal}
	<div ng-app ng-controller='CustomPacks'>
		<div class="option-group" ng-repeat="(section, data) in components">
			<h3>
				<select ng-change='changeOptType(data.id_optgroup, data.opttype)' ng-model='data.opttype' ng-options="k as v for (k,v) in opttypes"></select>
				<span class="name">{{section}}</span>
				<span class="remove" ng-click="removeSection(section)">X</span>
			</h3>
			<div class="product" ng-repeat="(id, product) in data.products">
				{{product.name}} <span ng-click="removeProduct(id, section)" class="remove">X</span>
			</div>
			<div class="search-box">
				<label>Add products...</label><input type="text" ng-model="queries[section]" ng-change="searchProducts(queries[section], section)"></input>
				<div class="product" ng-repeat="product in results[section]">
					<a ng-click="addProduct(product.id_product, section)">{{product.name}}</a>
				</div>
			</div>
		</div>
		<div id="new-section">
			<h3>Add a new section</h3>
			<label for="new-section-name">Name</label>
			<input id="new-section-name" ng-model="new_section_name" type="text"></input>
			<a ng-click="addSection(new_section_name)">Add</a>
		</div>
	</div>
{/literal}