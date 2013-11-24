<?php

require_once dirname(__FILE__).'/../../classes/CustomProduct.php';

class CustomPacksCustomizeModuleFrontController extends ModuleFrontController
{
	public function run()
	{
		if ($action = Tools::getValue('ajax-action'))
		{
			$method = "ajax".ucfirst($action);
			if(method_exists($this, $method))
			{
				$args = @json_decode(file_get_contents('php://input'), true);
				if ($args)
					foreach ($args as $key => $value)
						$_POST[$key] = $value;
				header('Content-type: application/json');
				die(json_encode($this->$method()));
			}
		}
	}

	public function ajaxUpdateCustomization()
	{
		$id_product = (int)Tools::getValue('id_product');
		
		if($id_product > 0)
		{
			$key = "custompacks_products_$id_product";
			$id_customization = (int)$this->context->cookie->$key;

			if($id_customization > 0)
			{
				Db::getInstance()->execute('DELETE FROM '._DB_PREFIX_.'fmdj_custompacks_customization_component WHERE id_customization='.(int)$id_customization);
				$values = array();
				foreach(Tools::getValue('cog') as $id_optgroup => $products)
				{
					foreach($products as $id_product)
					{
						$values[] = '('.(int)$id_customization.','.(int)$id_optgroup.','.(int)$id_product.')';
					}
				}
				$VALUES = implode(', ', $values);
				return Db::getInstance()->execute(
					'INSERT INTO '._DB_PREFIX_.'fmdj_custompacks_customization_component (id_customization, id_optgroup, id_product) VALUES '
					.$VALUES
				);
			}
		}

		return false;
	}
}