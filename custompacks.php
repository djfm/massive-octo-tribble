<?php

if (!defined('_PS_VERSION_'))
	exit;

require_once dirname(__FILE__).'/classes/CustomProduct.php';

class CustomPacks extends Module
{
	private $hooks = array(
		'actionObjectCartAddBefore',
		'actionObjectCartUpdateBefore',
		'actionObjectCartDeleteBefore',
		'displayAdminProductsExtra',
		'productFooter'
	);

	public function __construct()
	{
		$this->name = 'custompacks';
		$this->tab = 'front_office_features';
		$this->version = '0.1';
		$this->author = 'fmdj';

		parent::__construct();
	}

	private function query($statement)
	{
		return Db::getInstance()->execute(str_replace('PREFIX_', _DB_PREFIX_, $statement));
	}

	private function installSQL()
	{
		return $this->query(file_get_contents(dirname(__FILE__).'/sql/install.sql'));
	}

	private function uninstallSQL()
	{
		return $this->query(file_get_contents(dirname(__FILE__).'/sql/uninstall.sql'));
	}

	public function install()
	{
		return parent::install() && $this->installSQL() && $this->registerHooks();
	}

	public function uninstall()
	{
		return $this->uninstallSQL() && parent::uninstall();
	}

	private function registerHooks()
	{
		foreach ($this->hooks as $hook)
		{
			if (!$this->registerHook($hook))
				return false;
		}
		return true;
	}

	private function log($message)
	{
		if(!is_string($message))
		{
			$message = print_r($message,1);
		}

		$h = fopen('/tmp/mdev', 'a');
		fwrite($h, $message."\n");
		fclose($h);
	}

	public function getContent()
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
		return "";
	}

	public function hookActionObjectCartAddBefore($cart)
	{
		$this->log('hi cart');
	}

	public function hookActionObjectCartUpdateBefore($cart)
	{
		$this->log('up cart');
	}

	public function hookActionObjectCartDeleteBefore($cart)
	{
		$this->log('bye cart');
	}

	public function hookDisplayFooterProduct($params)
	{
		if(CustomProduct::findActiveByIdProduct($params['product']->id))
		{
			$cookie = $this->context->cookie;

			$key = "custompacks_products_{$params['product']->id}";

			$id_customization = (int)$cookie->$key;

			if($id_customization === 0)
			{
				$id_customization = CustomProduct::getNewCustomizationId();
			}

			$cookie->$key = $id_customization;

			$components = CustomProduct::getComponents($params['product']->id, $this->context->language->id, $id_customization);
			ddd($components);
			global $smarty;
			$smarty->assign('id_product', $params['product']->id);
			$smarty->assign('customize_url', $this->context->link->getModuleLink($this->name, 'customize'));
			$smarty->assign('components', $components);

			return $this->display(__FILE__, 'views/front/product.tpl');
		}
		else
			return "";
	}

	public function hookDisplayAdminProductsExtra($params)
	{
		global $smarty;

		$custom_product = CustomProduct::findActiveByIdProduct(Tools::getValue('id_product'));

		$smarty->assign('is_custom_pack', json_encode($custom_product ? true : false));
		$smarty->assign('custompacks_admin_url', json_encode($this->context->link->getAdminLink('AdminModules').'&configure='.$this->name));
		$smarty->assign('custompacks_css', file_get_contents(dirname(__FILE__).'/css/admin.css'));

		return $this->display(__FILE__, 'views/admin/adminproducts_tab.tpl');
	}

	private function ajaxSetIsCustomPack()
	{
		return CustomProduct::setIsCustomPack(Tools::getValue('id_product'), Tools::getValue('is_custom_pack') === 'true');
	}

	private function ajaxAddOptGroup()
	{
		$ok = CustomProduct::addOptGroup(Tools::getValue('id_product'), Tools::getValue('name'));

		return array('success' => ($ok === true), 'message' => ($ok === true ? '' : $this->l($ok)));
	}

	private function ajaxRemoveOptGroup()
	{
		$ok = CustomProduct::removeOptGroup(Tools::getValue('id_product'), Tools::getValue('name'));

		return array('success' => ($ok === true), 'message' => ($ok === true ? '' : $this->l($ok)));
	}

	private function ajaxGetComponents()
	{
		$obj = CustomProduct::getComponents(Tools::getValue('id_product'), $this->context->language->id);
		if($obj)
		{
			return array('success' => true, 'components' => $obj);
		}
		return array('success' => false);
	}

	private function ajaxFindProducts()
	{
		$query = trim(Tools::getValue('query'));
		if ($query==='')
			return array();

		$id_lang = $this->context->language->id;
		$results = Db::getInstance()->ExecuteS(
			 'SELECT p.id_product, l.name FROM '._DB_PREFIX_.'product p INNER JOIN '._DB_PREFIX_.'product_lang l ON l.id_product=p.id_product AND l.id_lang='.(int)$id_lang.' '
		    .'LEFT JOIN '._DB_PREFIX_.'fmdj_custompacks_product cp ON cp.id_product=p.id_product '
		    .'LEFT JOIN '._DB_PREFIX_.'product_attribute pa ON pa.id_product=p.id_product '
		    .'WHERE cp.id IS NULL AND l.name LIKE \'%'.pSQL($query).'%\' '
		    .'AND pa.id_product_attribute IS NULL '
		    .'AND p.active = 1 '
		    .'ORDER BY l.name '
		    .'LIMIT 10'
		);
		return $results;
	}

	private function ajaxAddProduct()
	{
		return CustomProduct::addProduct(Tools::getValue('id_product'), Tools::getValue('optgroup'), Tools::getValue('id_product_to_add'));
	}

	private function ajaxRemoveProduct()
	{
		return CustomProduct::removeProduct(Tools::getValue('id_product'), Tools::getValue('optgroup'), Tools::getValue('id_product_to_remove'));
	}

	private function ajaxChangeOptType()
	{
		return CustomProduct::changeOptType(Tools::getValue('id_optgroup'), Tools::getValue('opttype'));
	}
}